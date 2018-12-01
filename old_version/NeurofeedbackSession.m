classdef NeurofeedbackSession < handle
    % Reads xml into structs. Stores the information about the session.
    properties
        derived_signals % array of structures
        feedback_protocols %cell array of structures
        protocol_sequence % cell array of strings
        protocol_types % specifications of the protocols
        csp_settings
        sampling_frequency
        double_blind %boolean
        show_fb_count %boolean
        show_fb_rect %boolean
    end
    
    methods
        function self = NeurofeedbackSession(self) %#ok<INUSD>
            % ctor
            
            self.derived_signals        = [];
            self.feedback_protocols     = {};
            self.protocol_sequence      = {};
            self.protocol_types         = {};
            self.sampling_frequency     = 0;
            self.csp_settings           = {};
            self.double_blind           = 0;
            self.show_fb_count          = 0;
            self.show_fb_rect           = 0;
        end
        function self = LoadFromFile(self,fname)
            % the main function of the class;
            % reads the file and processes the settings
            % Input:
            %       fname - the name of the file, including folder path
            %
            nfs = xml2struct(fname);
            [folder, fn, ext] = fileparts(fname); %#ok<ASGLU>
            try %#ok<TRYNC>
            %sampling frequency
            self.sampling_frequency = str2double(nfs.NeurofeedbackSignalSpecs.fSamplingFrequency.Text);
            end
            try
                %double blind?
                if ~isempty(nfs.NeurofeedbackSignalSpecs.bDoubleBlind.Text)
                    if isnan(str2double(nfs.NeurofeedbackSignalSpecs.bDoubleBlind.Text))
                        warning('The value for double_blind is not a boolean. Setting it to 0')
                        self.double_blind = 0;
                    else
                        self.double_blind = str2double(nfs.NeurofeedbackSignalSpecs.bDoubleBlind.Text);
                    end
                        
                else
                    self.double_blind = 0;
                end
            catch
                self.double_blind = 0;
            end
            %display feedback count 
            try 
                if ~isempty(nfs.NeurofeedbackSignalSpecs.bShowFBCount.Text)
                    if isnan(str2double(nfs.NeurofeedbackSignalSpecs.bShowFBCount.Text))
                        warning('The value for show fb_count is not a boolean. Setting it to 0')
                        self.show_fb_count = 0;
                    else
                    self.show_fb_count = str2double(nfs.NeurofeedbackSignalSpecs.bShowFBCount.Text);
                    end
                else
                    self.show_fb_count = 0;
                end
            catch
                self.show_fb_count = 0;
            end
            % display feedback rectangle
             try 
                if ~isempty(nfs.NeurofeedbackSignalSpecs.bShowFBRect.Text)
                    if isnan(str2double(nfs.NeurofeedbackSignalSpecs.bShowFBRect.Text))
                        warning('The value for show fb rectangle is not a boolean. Setting it to 0')
                        self.show_fb_rect = 0;
                    else
                    self.show_fb_rect = str2double(nfs.NeurofeedbackSignalSpecs.bShowFBRect.Text);
                    end
                else
                    self.show_fb_rect = 0;
                end
             catch
                 self.show_fb_rect = 0;
            end
            %%derived signals
            
            ds = nfs.NeurofeedbackSignalSpecs.vSignals.DerivedSignal;
            for i = 1:length(ds)
                if isstruct(ds)
                    fields = fieldnames(ds(i));
                    d = ds(i);
                elseif iscell(ds)
                    fields = fieldnames(ds{i});
                    d = ds{i};
                end
                
                
                for j = 1: numel(fields)
                    if strcmp(fields{j},'SpatialFilterMatrix')
                        if ~isempty(d.SpatialFilterMatrix.Text)
                            [directory, filename, extension] = fileparts(d.SpatialFilterMatrix.Text); %#ok<ASGLU>
                            try
                                type = d.sType.Text;
                            catch
                                type = d.sType;
                            end
                            if ~strcmp(type,'composite')
                                if isempty(directory)
                                    try
                                        t = xml2struct(strcat(folder,'\',d.SpatialFilterMatrix.Text));
                                    catch 
                                         warning(['Spatial filter ' d.SpatialFilterMatrix.Text ' not found. Setting all channels'' weights to 1'])
                                         t = [];
                                    end
                                else
                                    try
                                        t = xml2struct(d.SpatialFilterMatrix.Text);
                                    catch
                                        warning(['Spatial filter ' d.SpatialFilterMatrix.Text ' not found. Setting all channels'' weights to 1'])
                                        t = [];
                                    end
                                end
                            else %if composite, filter is empty
                                t = [];
                            end
                        else
                            t = [];
                        end
                        
                        
                        if ~isempty(t)
                            chs = fieldnames(t.channels);
                            d.channels = cell(length(chs),2);
                            
                            for ch = 1:numel(chs)
                                
                                try
                                    d.channels(ch,1) = chs(ch);
                                    coeffs = str2num(t.channels.(chs{ch}).Text); %#ok<ST2NM>
                                    for coeff = 1:length(coeffs)
                                        
                                        d.channels{ch,coeff+1} = coeffs(coeff);
                                    end
                                catch
                                    chs{ch} %#ok<NOPRT>
                                end
                            end
                        else
                            d.channels = cell(0,0);
                        end
                    else
                        try
                            if str2num(d.(fields{j}).Text) || str2num(d.(fields{j}).Text) ==0 %#ok<ST2NM>
                                d.(fields{j}) = str2num(d.(fields{j}).Text); %#ok<ST2NM>
                            end
                        catch
                            d.(fields{j}) = d.(fields{j}).Text;
                        end
                    end
                end
                if ~strcmpi(d.sSignalName, 'Raw')
                    d.filters(1,1) = struct();
                    try
                    d.filters(1).range = [d.fBandpassLowHz d.fBandpassHighHz];
                    catch
                        warning('Bandpass frequencies are not set for the signal %s. Setting them to [8 16]',d.sSignalName);
                        d.filters(1).range = [ 8  16];
                    end
                    d.filters(1).order = 4;
                    d.filters(1).mode = 'bandpass';
                else
                    d.filters = cell(1,0);
                end
                
                
                if exist(strcat(folder,'\',d.sSignalName,'_statvalues.mat'),'file')
                    d.statvalues = load(strcat(folder,'\',d.sSignalName,'_statvalues.mat'));
                end
                if ~strcmp(d.sType,'composite')
                    self.derived_signals{end+1} = d;
                end
            end
            %protocols
            self.protocol_types = nfs.NeurofeedbackSignalSpecs.vProtocols.FeedbackProtocol;
            for i = 1:length(self.protocol_types)
                fields = fieldnames(self.protocol_types{i});
                pr = self.protocol_types{i};
                for j = 1: numel(fields)
                    
                    try
                        % upd on 2015-06-02
                        if any(str2num(pr.(fields{j}).Text)) || all(str2num(pr.(fields{j}).Text)) ==0 %#ok<ST2NM>
                            pr.(fields{j}) = str2num(pr.(fields{j}).Text); %#ok<ST2NM>
                        else
                            pr.(fields{j}) = pr.(fields{j}).Text;
                        end
                        
                    catch  err
                        switch err.identifier
                            %                             case 'MATLAB:nonLogicalConditional'
                            %
                            %                                 pr.(fields{j}) = pr.(fields{j}).Text;
                            case  'MATLAB:nonExistentField'
                                pr.(fields{j}) = pr.(fields{j});
                        end
                    end
                    
                    
                end
                self.protocol_types{i} = pr;
            end
            %%protocol_sequence
            %%% upd on 2015-05-13
            show_as = {};
            string = {};
            try
                seq = nfs.NeurofeedbackSignalSpecs.vPSequence.s;
                %ps = {};
                if length(seq) == 1
                    self.protocol_sequence{end+1} = seq.Text;
                else
                    for s = 1:length(seq)
                        self.protocol_sequence{end+1} = seq{s}.Text;
                        if isfield(seq{s},'Attributes')
                            if isfield(seq{s}.Attributes,'show_as')
                                show_as{end+1} = seq{s}.Attributes.show_as;
                            else
                                show_as{end+1} = seq{s}.Text;
                            end
                            if isfield(seq{s}.Attributes,'string')
                                string{end+1} = seq{s}.Attributes.string;
                            else
                                string{end+1} = '';
                            end
                        else
                            show_as{end+1} = seq{s}.Text;
                            string{end+1} = '';
                        end
                    end
                end
                
            catch err
                if strcmp(err.identifier, 'MATLAB:nonExistentField')
                    seq = nfs.NeurofeedbackSignalSpecs.vPSequence.loop;
                    %ps = {};
                    for ss = 1:length(seq)
                        for a = 1:str2double(seq{ss}.Attributes.count)
                            for p = 1:length(seq{ss}.s)
                                if length(seq{ss}.s) == 1
                                    self.protocol_sequence{end+1} = seq{ss}.s(p).Text;
                                    if isfield(seq{ss}.s(p), 'Attributes')
                                        if isfield(seq{ss}.s(p).Attributes, 'show_as')
                                            
                                            show_as{end+1} = seq{ss}.s(p).Attributes.show_as;
                                        else
                                            show_as{end+1} = seq{ss}.s(p).Text;
                                        end
                                        if isfield(seq{ss}.s(p).Attributes, 'string')
                                            string{end+1} = seq{ss}.s(p).Attributes.string;
                                        else
                                            string{end+1} = '';
                                        end
                                        
                                    else
                                        show_as{end+1} = seq{ss}.s(p).Text;
                                        string{end+1} = '';
                                    end
                                    
                                else
                                    self.protocol_sequence{end+1} = seq{ss}.s{p}.Text;
                                    if isfield(seq{ss}.s{p}, 'Attributes')
                                        if isfield(seq{ss}.s{p}.Attributes, 'show_as')
                                            show_as{end+1} = seq{ss}.s{p}.Attributes.show_as;
                                        else
                                            show_as{end+1} = seq{ss}.s{p}.Text;
                                        end
                                        if isfield(seq{ss}.s{p}.Attributes, 'string')
                                            string{end+1} = seq{ss}.s{p}.Attributes.string;
                                        else
                                            string{end+1} = '';
                                        end
                                    else
                                        show_as{end+1} = seq{ss}.s{p}.Text;
                                        string{end+1} = '';
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
            
            
            
            %%%
            
            
            for j = 1: length(self.protocol_sequence)
                for i = 1:length(self.protocol_types)
                    if strcmp(self.protocol_sequence{j},self.protocol_types{i}.sProtocolName)
                        rtp = RealtimeProtocol(1,self.protocol_types{i});
                        if ~isempty(show_as) && isempty(rtp.show_as)
                            try
                            if self.double_blind && ~isempty(strfind(lower(show_as{j}),'mock'))
                                rtp.show_as = 'Feedback color';
                            else
                        rtp.show_as = show_as{j};
                            end
                            catch
                                308 %#ok<NOPRT>
                            end
                        end
                         if ~isempty(string) && ~isempty(string{j})
                             rtp.string_to_show = string{j};
                         end
                        self.feedback_protocols{end+1} = rtp;
                        
                        %rtp.set_ds_index(self.protocol_sequence);
                    end
                end
            end
            %csp settings if exist
            try
                csp = nfs.NeurofeedbackSignalSpecs.CSPSettings;
                
                fields = fieldnames(csp);
                if length(fields) == 1 && strcmp(fields,'Text')
                    csp = [];
                else
                    
                    for i = 1:numel(fields)
                        try
                            % upd on 2015-06-02
                            if any(str2num(csp.(fields{i}).Text)) || all(str2num(csp.(fields{i}).Text)) ==0 %#ok<ST2NM>
                                csp.(fields{i}) = str2num(csp.(fields{i}).Text); %#ok<ST2NM>
                            else
                                csp.(fields{i}) = csp.(fields{i}).Text;
                            end
                            
                        catch  err
                            switch err.identifier
                                %                             case 'MATLAB:nonLogicalConditional'
                                %
                                %                                 pr.(fields{j}) = pr.(fields{j}).Text;
                                case  'MATLAB:nonExistentField'
                                    csp.(fields{i}) = csp.(fields{i});
                            end
                        end
                    end
                    
                end
            catch err
                switch err.identifier
                    case 'MATLAB:nonExistentField'
                        csp = [];
                end
                
            end
            try
            if ~isnumeric(csp.iNComp)
                warning('csp.iNComp is not a double. Setting it = 2');
                csp.iNComp = 2;
            end
            catch
                363 %#ok<NOPRT>
            end
            try
            if ~isnumeric(csp.dInitBand)
                warning('csp.dInitBand is not double. Setting it = [8 16]');
                csp.dInitBand = [8 16];
            elseif length(csp.dInitBand) ~=2
                warning('csp.dInitBand must be two values. Setting it = [8 16]');
                csp.dInitBand = [8 16];
            end
            catch
                374 %#ok<NOPRT>
            end
            try
            self.csp_settings = csp;
            catch
                379 %#ok<NOPRT>
            end
        end
    end
    
    
    
    
end


