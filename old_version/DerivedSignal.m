classdef DerivedSignal < handle
    % The class stores information and manages data of the signal.
    % The DerivedSignal receives raw data and processes it according to 
    % its parameters (temporal and spatial filters)
    % Stores all the data for the experiment in collect_buff
    % 
    % More about the parameters: see the properties section 
    
    
    properties
        
        spatial_filter % a vector or several vectors of channel coefficients
        temporal_filter %array of digitalFilter(s)
        ring_buff % a small circVBuf used for plotting and calculating feedback
        %current_filename % name of data file to collect data and calculate stdev
        %window_size
        %window_coefficients 
        signal_name %string; the default = 'dummy'
        data % temporarily stores the incoming data
        channels % cell array of strings; used channels; default = empty;
        all_channels % cell array of strings; all received channels; default - empty
        channels_file
        collect_buff %a large circVBuf used for collecting all the data of
                    % the experiment
        channels_indices %cell{string, int}
        filtered % boolean; temp for debugging
        composite_montage % not used
        sampling_frequency %double; the sampling_frequency of the stream; default = 500;
        %channels_file %
        data_length % integer; a parameter of collect_buff; default = plot_length * 2
        plot_length % integer; a parameter of ring_buff; default = 1000;
        signal_type % plain (spatial filter == vector), combined (spatial 
                    % filter == several vectors) or composite (the values 
                    % are obtained from another DerivedSignals (parents))
                    % default = 'plain'
        parents % array of DerivedSignals
        op %string; operator ('+','-')
        statvalues % array of doubles; values used to update statistics
        upd_stats_idc %update_stats_indices; if the stats were updated in 
                    %current session, a pair of doubles; else zero;
        file_av % double; average from file
        file_std %double; std from file
        ch1 %whether the filter used is chebyshev type 1 filter; else
            % chebyshev type 2
       
    end
    
    methods
        
        function self = DerivedSignal(self,signal, sampling_frequency, data_length,channels,plot_length) %#ok<INUSL>
            % ctor
            % Inputs:
            %       signal - struct
            %       sampling_frequency - the sampling frequency of the stream
            %       data_length - the estimated length of recordings
            %       channels - the channels of the stream
            %       plot_length - size of the data plotted on the screen
            %
            
            %chebyshev type1 ? else chebyshev type 2
            self.ch1 = 0;
            
            if nargin < 6
                self.plot_length = 1000;
            else
                self.plot_length = plot_length;
            end
            
            if nargin < 5
                self.all_channels = {};
            else
                self.all_channels = channels;
            end
            
            if nargin < 4
                self.data_length = self.plot_length * 2;
            else
                self.data_length = data_length;
            end
            
            if nargin < 3
                self.sampling_frequency = 500;
            else
                self.sampling_frequency = sampling_frequency;
            end
            
            if nargin < 2
                self.signal_name = 'dummy';
                self.channels = {};
                self.signal_type = 'plain';
            else
                self.signal_name = signal.sSignalName;
                try
                self.statvalues = signal.statvalues.sv;
                catch
                    self.statvalues = [];
                    
                end
                if ~isempty(signal.channels)
                    
                    self.channels = signal.channels;
                elseif ~isempty(self.all_channels)
                    
                    self.channels = cell(length(self.all_channels),2);
                    for ch = 1:length(self.all_channels)
                        self.channels(ch,1) = self.all_channels(ch);
                        self.channels{ch,2} = 1;
                    end
                elseif isempty(self.all_channels)
                    self.channels = {};
                end
                if isfield(signal,'filters')
                    
                    self.temporal_filter = cell(1,length(signal.filters));
                    for c = 1:length(self.temporal_filter)
                        self.temporal_filter{c}.order = signal.filters(c).order;
                        self.temporal_filter{c}.range = signal.filters(c).range;
                        self.temporal_filter{c}.mode = signal.filters(c).mode;
                        %cheby2
                        if ~self.ch1
                        self.temporal_filter{c}.filter = CreateFilter(self.temporal_filter{c}.range,sampling_frequency);
                        %designfilt('bandpassiir','StopbandFrequency1',1,'PassbandFrequency1',self.temporal_filter{c}.range(1),'PassbandFrequency2',self.temporal_filter{c}.range(2),...
                            %'StopbandFrequency2', 50, 'StopbandAttenuation1',30,'PassbandRipple',1,'StopbandAttenuation2',30,'DesignMethod','cheby2','SampleRate', sampling_frequency);
                        else
                        [z, p, k] = cheby1(self.temporal_filter{c}.order,1,self.temporal_filter{c}.range/(sampling_frequency/2),self.temporal_filter{c}.mode);
                        [self.temporal_filter{c}.B, self.temporal_filter{c}.A] = zp2tf(z,p,k);
                        self.temporal_filter{c}.Zf = zeros(max(length(self.temporal_filter{c}.A),length(self.temporal_filter{c}.B))-1,1);
                        self.temporal_filter{c}.Zi = zeros(max(length(self.temporal_filter{c}.A),length(self.temporal_filter{c}.B))-1,1);
                        end
                    end
                else
                    self.temporal_filter = cell(0,0);
                end
                try
                    self.signal_type = signal.sType;
                catch
                    self.signal_type = 'plain';
                end
            end
            
            self.channels_indices = zeros(1,length(self.channels));
            if strcmpi(self.signal_name,'raw');
                self.spatial_filter = ones(length(self.all_channels),1);
            else
                self.spatial_filter = [];%zeros(length(self.all_channels),1);
            end
            
            for i = 1:length(self.all_channels)
                for j = 1:size(self.channels,1)
                    try
                        if strcmp(self.all_channels{i},self.channels{j,1})
                            
                            self.channels_indices(j) = i;
                        end
                    catch i,j %#ok<NASGU,NOPRT>
                    end
                    
                end
            end
            
            self.collect_buff = 0;
            self.ring_buff = 0;
            self.parents = {};
            
        end
    
        function UpdateSpatialFilter(self,sp_filter, raw_signal,bad_channels)
            % This function creates or updates the spatial filter of the 
            % DerivedSignal
            % Inputs:
            %       sp_filter - numeric of doubles or cell(channel_names, coefficients)
            %       raw_signal - DerivedSignal that is 'raw'; contains
            %                   all channels
            %       bad_channels - channels that are 'noisy' and need to be
            %                   eliminated
            % If the sp_filter is not provided, the spatial_filter is set
            %       to ones;
            %
            % >> self = DerivedSignal();
            % >> self.spatial_filter = [0 0 0]';
            % >> self.UpdateSpatialFilter([1 0 1]);
            % >> self.spatial_filter
            %
            %ans =
            %
            %     1
            %     0
            %     1
            % >> self.UpdateSpatialFilter({'A' 1; 'B' 2; 'C' 3; 'D' 4;})
            % >> self.spatial_filter
            %
            %ans =
            %
            %     1
            %     2
            %     3
            %     4
            % >> self.channels_indices
            %
            %ans =
            %
            %     1
            %     2
            %     3
            %     4
            % >> self.channels
            %
            %ans =
            %
            % 'A' [1] 'B' [2] 'C' [3] 'D' [4]
            % >> self.UpdateSpatialFilter({'B' 16; 'C' 0.5})
            % >> self.spatial_filter
            %
            %ans =
            %
            %     1.0000
            %     16.0000
            %     0.5000
            %     4.0000
            % >> bads = {'C','D'};
            % >> self.ZeroOutBadChannels(bads);
            % >> self.spatial_filter
            %
            %ans =
            %
            %     1
            %     16
            %     0
            %     0
            % >> size(self.spatial_filter,2)
            %
            %ans =
            %
            % 1
            % >> signal_channels = {'G' 1;'E' 0.01; 'A' 8.24};
            % >> hardware_channels = {'A','B','C','D','E','F','G','H'};
            % >> signal_struct = struct('sSignalName','test');
            % >> signal_struct.channels = signal_channels;
            % >> self = DerivedSignal(1,signal_struct,100,1000,hardware_channels,100);
            % >> self.channels_indices
            %
            %ans =
            %
            % 7 5 1
            
            if nargin < 2 || isempty(sp_filter) && ~isempty(self.all_channels)
                %if spatial filter is not provided
                self.spatial_filter = ones(length(self.all_channels),1);


            elseif iscell(sp_filter) && size(sp_filter,2) > 1%channels cell array
                self.spatial_filter = zeros(length(self.all_channels),1);
                %self.channels = sp_filter;
                channel_names = {};
                for i = 1:size(sp_filter,1)
                    channel_names{end+1} = sp_filter{i,1};
                end
                if ~isempty(self.all_channels)
                    for idx = 1:size(sp_filter,1)
                        for ch = 1:length(self.all_channels)
                            if strcmp(sp_filter{idx,1},self.all_channels(ch)) && ~isempty(nonzeros(strncmpi(self.all_channels{ch},self.channels(:,1),5)))
                                %if spatial filter contains a used channel
                                for c = 1:length(self.channels)
                                    if strcmp(sp_filter{idx,1},self.channels{c,1})
                                        for coeff = 2:size(sp_filter,2)
                                            self.channels{c,coeff} = sp_filter{idx,coeff};
                                            self.spatial_filter(self.channels_indices(c),coeff-1) = sp_filter{idx,coeff};
                                        end
                                        break;
                                    end
                                end
                            end
                        end
                    end
                else
                    self.spatial_filter = [];
                    for idx = 1:length(sp_filter)
                        self.all_channels{idx} = sp_filter{idx,1};
                        self.channels{idx,1} = sp_filter{idx,1};
                        self.channels_indices(idx) = idx;
                        for coeff = 2:size(sp_filter,2)
                            self.channels{idx,coeff} = sp_filter{idx,coeff};
                            self.spatial_filter(idx,coeff-1) = sp_filter{idx,coeff};
                        end
                    end
                    
                    
                    
                    
                    
                end
                if strcmpi(self.signal_name, 'raw')
                    for s_ch = 1:length(sp_filter)
                        if isempty(nonzeros(strcmp(self.all_channels,channel_names{s_ch})))
                            warning(['The channel ',channel_names{s_ch},' is not transmitted by the device.'])
                        end
                    end
                else
                    if nargin>2
                        for s_ch = 1:size(sp_filter,1)
                            
                            if isempty(nonzeros(strcmp(raw_signal.channels(:,1),channel_names{s_ch})))
                                warning(['The channel ',channel_names{s_ch},' is not presented in the raw data.'])
                            elseif ~isempty(nonzeros(strcmp(bad_channels, channel_names{s_ch})))
                                warning(['The channel ',channel_names{s_ch}, ' was eliminated from the raw signal.']);
                            end
                        end
                    end
                end
            elseif isnumeric(sp_filter) && ~isempty(self.channels_indices) && min(size(sp_filter)) == 1 %vector
                %apply sp_filter vector acc to channels_indices
                for idx = 1:length(self.channels_indices)
                    self.spatial_filter(self.channels_indices(idx)) = sp_filter(self.channels_indices(idx));
                end
                if size(self.spatial_filter,2) > 1
                    self.spatial_filter = self.spatial_filter';
                end
            elseif isnumeric(sp_filter)
                %apply sp_filter vector as is
                if size(sp_filter,2) > 1
                    self.spatial_filter = sp_filter';
                else
                    self.spatial_filter = sp_filter;
                end
                if isempty(self.channels_indices)
                    self.channels_indices = 1:size(self.spatial_filter,2);
                end
                %             elseif isstruct(sp_filter)
                %                 channel_names = {};
                %                 for i = 1:length(sp_filter)
                %                     channel_names{end+1} = sp_filter(i).channel_name;
                %                 end
                %                 if strcmpi(self.signal_name, 'raw')
                %                     for idx = 1:length(sp_filter)
                %                         for ch = 1:length(self.all_channels)
                %                             if strcmp(sp_filter(idx).channel_name,self.all_channels(ch)) && ~isempty(nonzeros(strncmpi(self.all_channels{ch},self.channels(:,1),5)))
                %                                 self.spatial_filter(ch) = sp_filter(idx).coefficient;
                %                                 for c = 1:length(self.channels)
                %                                     if strcmp(sp_filter(idx).channel_name,self.channels{c,1})
                %                                         self.channels{c,2} = sp_filter(idx).coefficient;
                %                                     end
                %                                 end
                %                             end
                %                         end
                %                     end
                %                 else
                %                     self.spatial_filter = zeros(1,length(raw_signal.spatial_filter));
                %                     for idx = 1:length(sp_filter)
                %                         for ch = 1:length(raw_signal.all_channels)
                %                             if strcmp(sp_filter(idx).channel_name,raw_signal.all_channels{ch}) && ~isempty(nonzeros(strncmpi(raw_signal.all_channels{ch},self.channels(:,1),5)))
                %                                 self.spatial_filter(ch) = sp_filter(idx).coefficient;
                %                                 for c = 1:length(self.channels)
                %                                     if strcmp(sp_filter(idx).channel_name,self.channels{c,1})
                %
                %                                         self.channels{c,2} = sp_filter(idx).coefficient;
                %                                         break;
                %                                     end
                %                                 end
                %                                 break;
                %                             end
                %                         end
                %                     end
                %
                %                 end
                
            end
            
            %             if isempty(self.channels)
            %                 self.channels = cell(length(self.all_channels),2);
            %                 for ch = 1:length(self.channels)
            %                     if ~isempty(self.all_channels)
            %                         self.channels{ch,1} = self.all_channels{ch};
            %
            %                     else
            %                         self.channels{ch,1} = ch;
            %                     end
            %                     self.channels{ch,2} = self.spatial_filter{ch};
            %                 end
            %             end
            if size(self.channels,2)
                for i = 1:size(self.channels,2)
                    chs(:,i) = self.channels(self.channels_indices(1,:)~=0,i);
                end
                %             chs(:,1) = self.channels(self.channels_indices(1,:)~=0,1);
                %             chs(:,2) = self.channels(self.channels_indices(1,:)~=0,2);
                %             chs(:,3) = self.channels(self.channels_indices(1,:)~=0,3);
                self.channels = chs;
                self.channels_indices = nonzeros(self.channels_indices);
            else
                chs = cell(size(self.spatial_filter,1),2);
                for i = 1:size(self.spatial_filter,1)
                    chs{i,1} = num2str(i);
                    chs{i,2} = self.spatial_filter(i);
                end
                self.channels = chs;
            end
            if ~isempty(self.collect_buff)
                if strcmpi(self.signal_name, 'raw')
                    self.collect_buff = circVBuf(self.data_length, length(self.channels), 0);
                    self.ring_buff = circVBuf(fix(self.plot_length*self.sampling_frequency*1.5),length(self.channels), 0);
%                 elseif self.lda
%                     self.collect_buff = circVBuf(self.data_length,size(self.spatial_filter,2),0);
%                     self.ring_buff = circVBuf(fix(self.plot_length*self.sampling_frequency*1.5),size(self.spatial_filter,2), 0);
                else
                    self.collect_buff = circVBuf(self.data_length,1,0);
                    self.ring_buff = circVBuf(fix(self.plot_length*self.sampling_frequency*1.5),1, 0);
                end
                
            end
        end
        
        function UpdateTemporalFilter(self,size,range,order,mode)
            % This function creates or updates temporal filter of the 
            % DerivedSignal
            % Inputs:
            %       size - the number of vectors of coefficients (default: 1)
            %       range - the bandpass range of the filter (default: [8 16])
            %       order - the order of the filter (if any) (default: 3)
            %       mode - the mode of the filter (default: bandpass)
            %
            
            % create cheby2 filter unless self.ch1 = 1 then cheby1
            %size - size of spatial_filter
            if(nargin<5)
                mode = 'bandpass';
            end;
            if(nargin<4)
                order = 3;
            end;
            if nargin < 3
                range = [8 16];
            end
            if nargin < 2 || size < 1
                size = 1;
            end
            
            self.temporal_filter{1}.range = range;
             %cheby2
             if ~self.ch1
             self.temporal_filter{1}.filter = CreateFilter(self.temporal_filter{1}.range,self.sampling_frequency);
             else
                             [z, p, k] = cheby1(order,1,self.temporal_filter{1}.range/(self.sampling_frequency/2),mode);
                             [self.temporal_filter{1}.B, self.temporal_filter{1}.A] = zp2tf(z,p,k);
                 
                             self.temporal_filter{1}.Zf = zeros(max(length(self.temporal_filter{1}.A),length(self.temporal_filter{1}.B))-1,min(size));
                             self.temporal_filter{1}.Zi = zeros(max(length(self.temporal_filter{1}.A),length(self.temporal_filter{1}.B))-1,min(size));
             end
        end
        
        
        function Apply(self, newdata,recording)
            % This function processes the incoming data
            % Applies temporal and spatial filter and (optionally) saves the 
            % result into collect_buff
            % Inputs:
            %       newdata - the array of data (channels,samples)
            %       recording - boolean; whether to push data into 
            %               collect_buff
            % 
            %
            
            % >> self = DerivedSignal();
            % >> self.sampling_frequency = 500;
            % >> self.UpdateSpatialFilter([1 0 1 1]);
            % >> size(self.spatial_filter)
            %
            %ans =
            %
            % 4 1
            % >> self.UpdateTemporalFilter(1, [10 15], 3, 'bandpass');
            % >> self.Apply(ones(4,10),true);
            % >> self.ring_buff.raw(self.ring_buff.fst:self.ring_buff.lst)
            %
            %ans =
            %
            % 0.0000    0.0003    0.0011    0.0026    0.0050    0.0085    0.0131    0.0186    0.0248    0.0315
            % >> self.ring_buff.raw(self.ring_buff.fst:self.ring_buff.lst) == self.collect_buff.raw(self.collect_buff.fst:self.collect_buff.lst)
            %
            %ans =
            %
            % 1
            if nargin < 3
                recording = 0;
            end
            
            %do projection, i.e. apply spatial filter(s)
            if strcmpi(self.signal_name, 'raw')
                self.data = zeros(length(self.channels), size(newdata,2));
                %select only the channels we need
                
                self.data = newdata(self.channels_indices,:);
                self.ring_buff.append(self.data');
                if recording
                    self.collect_buff.append(self.data');
                end
                
%             elseif self.lda
%                 if all(size(newdata))
%                 try
%                     
%                
%                 sz = filter(self.temporal_filter{1}.filter,newdata')';
%                 res = self.spatial_filter' * sz;
%                     
%                 catch
%                     457 %#ok<NOPRT>
%                 end
%                 try
%                 self.ring_buff.append(res');
%                         if recording
%                             self.collect_buff.append(res');
%                         end
%                 catch
%                     461 %#ok<NOPRT>
%                 end
%                 end
            elseif strfind(lower(self.signal_type), 'combined')
                sz = zeros(size(self.spatial_filter,2),size(newdata,2));
                for i =1:size(self.spatial_filter,2)
                    sz(i,:) = (self.spatial_filter(:,i)' * newdata); %.^2;
                end
                
                if size(sz,2) > 5
                    %add selection
                    for i = 1:size(sz,1)
                        for f = 1:length(self.temporal_filter)
                             %%%%% do filtering
                            if ~self.ch1
                                
                                sz(i,:) = filter(self.temporal_filter{f}.filter,sz(i,:));
                            else
                                clear sztmp
                                
                                
                                [sztmp, Zftmp] = filter(self.temporal_filter{f}.B,  self.temporal_filter{f}.A, sz(i,:)', self.temporal_filter{f}.Zi(:,i));
                                                            sz(i,:) = sztmp';
                                                            self.temporal_filter{f}.Zf(:,i) = Zftmp;
                                                            %update the internal initial state variable
                                                            self.temporal_filter{f}.Zi(:,i) = self.temporal_filter{f}.Zf(:,i);
                            end
                        end
                    end
                    
                    
                    %res = sqrt(sum(sz.^2,1));
                    
                        res = sz;
                    try
                        self.ring_buff.append(res');
                        if recording
                            self.collect_buff.append(res');
                        end
                    catch
                        451 %#ok<NOPRT>
                    end
                    
                end
                
                
                %there goes a piece of code which performs calculation of
                %derived signal as follows
                % signal = sqrt(sum((sp_fn* data).^2) for n = 1:length(sp_f))
            elseif strfind(lower(self.signal_type), 'composite')
                data_length = size(newdata,2);
                data1 = self.parents{1}.ring_buff.raw(self.parents{1}.ring_buff.lst - data_length+1:self.parents{1}.ring_buff.lst);
                data2 = self.parents{2}.ring_buff.raw(self.parents{2}.ring_buff.lst - data_length+1:self.parents{2}.ring_buff.lst);
                if strcmp(self.op,'+')
                    res = abs(data1) + abs(data2);
                elseif strcmp(self.op,'-')
                    res = abs(data1) - abs(data2);
                end
                try
                    self.ring_buff.append(res);
                    if recording
                        self.collect_buff.append(res);
                    end
                catch
                   474 %#ok<NOPRT>
                end
                
            else
                %usual single derived signal
                
                %sz = self.spatial_filter*self.composite_montage * newdata;
                sz = self.spatial_filter'*newdata;
                if size(sz,2) > 5
                    %add selection
                    for i = 1:size(sz,1)
                        for f = 1:length(self.temporal_filter)
                            if ~self.ch1
                                sz(i,:) = filter(self.temporal_filter{f}.filter,sz(i,:));
                            else
                                
                                [sztmp, Zftmp] = filter(self.temporal_filter{f}.B,  self.temporal_filter{f}.A, sz(i,:)', self.temporal_filter{f}.Zi(:,i));
                                sz(i,:) = sztmp';
                                self.temporal_filter{f}.Zf(:,i) = Zftmp;
                                %[sz(i,:), self.temporal_filter{f}.Zf(:,i) ] = filter(self.temporal_filter{f}.B,  self.temporal_filter{f}.A, sz(i,:)', self.temporal_filter{f}.Zi(:,i));
                                self.temporal_filter{f}.Zi(:,i) = self.temporal_filter{f}.Zf(:,i);
                            end
                        end
                    end
                    
                    
                    try
                        self.ring_buff.append(sz');
                        if nargin > 2 && recording
                            self.collect_buff.append(sz');
                        end
                    catch
                        501 %#ok<NOPRT>
                    end
                end
            end
            
        end
        function ZeroOutBadChannels(self,bad_channels)
            % Eliminates noisy channels from processing by setting their
            % coefficients = 0;
            % Input:
            %       bad_channels - cell of strings
            % Modifies self.spatial_filter(channels == bad_channels) = 0;
            %
            for bad = 1:length(bad_channels)
                for ch = 1:length(self.all_channels)
                    if strcmp(self.all_channels(ch),bad_channels{bad})
                        self.spatial_filter(ch) = 0;
                    end
                end
            end
        end
    end
end

