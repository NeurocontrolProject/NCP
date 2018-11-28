classdef RealtimeProtocol < handle
    % Contains description of a recorded protocol. 
    % 
    %About the protocol parameters: see the properties section
    properties
        protocol_name %string; matches the protocol_name in protocol sequence, default = empty string
        window_duration %feedback window in milliseconds, default = 0;
        window_size % feedback window in samples, default = 0;
        to_update_statistics % (boolean) whether or not to update avg and std, default = false;
        protocol_duration % duration in seconds, default = 0;
        protocol_size %duration in samples, default = 0;
        actual_protocol_size %samples already recorded, default = 0;
        stop_after %boolean; whether to stop after recording the protocol, default = false;
        string_to_show %string to show on subject screen, default = empty string
        fb_type % string; mock or real
        %band % double; ?
        n_comp % number of components(half of feature vectors) for csp
        init_band %the starting band to calculate; for csp
        show_as %string to show in the main window
        show_counter %boolean; counts discrete feedback
        threshold % threshold for discrete feedback, sigmas
        fb_source % double; vector of feedback values
        fb_frequency % double; the frequency of the mock feedback
        fbSource % filename or 'random'
        mock_fb_mean %self-descriptive
        mock_fb_sigma %
        discrete_mock_fb %
        
        
    end 
   
    methods
        function self = RealtimeProtocol(self,protocol_type,sampling_frequency)  %#ok<INUSL>
            % ctor
            % Inputs:
            %       protocol_type - struct (made from xml) with specifications of the protocol
            %       sampling_frequency - the sampling_frequency of the stream
            %
            if nargin < 2
                self.protocol_name           = '';
                self.to_update_statistics    = false;
                self.window_duration         = 0;
                self.protocol_duration       = 0;
                self.stop_after              = false;
                self.string_to_show          = '';
                self.window_size             = 0;
                self.protocol_size           = 0;
                self.show_counter            = 0;
                self.threshold               = 1;
                
                
                
            elseif nargin >= 2
                self.protocol_name = protocol_type.sProtocolName;
                self.to_update_statistics    = protocol_type.bUpdateStatistics;
                self.protocol_duration =  protocol_type.fDuration;
                self.stop_after = protocol_type.bStopAfter;
                self.string_to_show = protocol_type.cString;
                try 
                self.show_counter = protocol_type.bShowCounter;
                catch
                    self.show_counter = 0;
                end
                try 
                    self.threshold = protocol_type.fThreshold;
                catch
                    self.threshold = 1;
                end

%                 try %#ok<TRYNC>
%                     self.band = protocol_type.dBand;
%                 end
                try %#ok<TRYNC>
                    self.fb_type = protocol_type.sFb_type;
                end
                try %#ok<TRYNC>
                    self.window_duration = protocol_type.nMSecondsPerWindow;
                end
                try %#ok<TRYNC>
                    self.n_comp = protocol_type.NComp;
                end
%                 try %#ok<TRYNC>
%                     
%                     message = '';
%                     if any([strcmpi(protocol_type.fbSource,'random'), exist(protocol_type.fbSource,'file')])
%                         self.ReadMockFbFile(protocol_type.fbSource);
%                     else
%                         if isempty(protocol_type.fbSource)
%                             message = 'Mock feedback source is not specified';
%                         elseif  ~exist(protocol_type.fbSource,'file')
%                             message = 'Mock feedback file cannot be found';
%                         end
%                         %prompt a user
%                         self.fb_source = 0;
%                         while ~self.fb_source
%                             button = questdlg(message,'Set mock feedback','Use random','Select a file', 'Use real feedback','Use random');
%                             switch button
%                                 case 'Use random'
%                                     self.fb_source = 'Random';
%                                 case 'Select a file'
%                                     [fname, pathname, index] = uigetfile('*.bin'); %#ok<ASGLU>
%                                     if fname ~= 0
%                                         self.ReadMockFbFile(fname,pathname);
%                                     end
%                                 case 'Use real feedback'
%                                     self.fb_type = 'Color intensity';
%                                     self.protocol_name = 'Feedback_color';
%                                     self.show_as = 'Feedback_color';
%                                     self.fb_source = 'Real';
%                             end
%                         end
%                                         
%                                         
%                                     
%                                 
%                                 
%                         
%                     
%                         
%                     
%  
%                         
%                     end
%                     
%                 end
                
                if strfind(lower(self.protocol_name),'mock')
                    self.fb_type = 'mock';
                    self.fbSource = protocol_type.fbSource;
%                     if ~exist(protocol_type.fbSource,'file')
%                         self.fb_source = 'Random';
%                     end
                end
                self.window_size             = 0;
                self.protocol_size           = 0;
            end
            if nargin == 3
                self.protocol_size = self.protocol_duration*sampling_frequency;
                self.window_size = self.window_duration*sampling_frequency/1000;
            end
            
            self.actual_protocol_size = 0;
            
        end
        
        function Recalculate(self,sampling_frequency,fb_refresh_rate)
            % Recalculates the size (in samples) of the protocol given the sampling frequency
            % resamples the mock feedback 
            % Inputs:
            %       sampling_frequency - the sampling frequency of the stream
            %       fb_refresh_rate - the rate of refreshing of feedback (is necessary if mock feedback is used)
            %
            self.protocol_size = self.protocol_duration*sampling_frequency;
            self.window_size = self.window_duration*sampling_frequency/1000;
            %recalculate mock feedback
            if nargin > 2 && ~isempty(self.fb_frequency) && fb_refresh_rate < self.fb_frequency && isnumeric(self.fb_source)
                self.fb_source = resample(self.fb_source,round((sampling_frequency/1000)/fb_refresh_rate),self.fb_frequency);
                self.mock_fb_mean = mean(self.fb_source);
                self.mock_fb_sigma = std(self.fb_source);
                self.discrete_mock_fb = zeros(size(self.fb_source));
                
            end
           
          
        end
        

        function ReadMockFbFile(self,fname,pathname)
            % reads the file with mock_feedback into self.fb_source
            % Inputs:
            %       fname - filename
            %       pathname - folder name
            % If fname is a '.mat' file, the filename should be formatted as
            % 'Mock_feedback_NHz.mat' where N is an integer.
            % If fname is a '.bin' file, the filename is as follows
            % 'Pr_N Protocol_name Protocol_show_as Duration.bin' where Pr_N
            % is an integer, Protocol_name and Protocol_show_as are strings 
            % and Duration is double. The feedback frequency is calculated as 
            % size of the file/Duration
            %
            [pathstr,name,ext] = fileparts(fname) ; %#ok<ASGLU>
            if strcmp(ext,'.mat') % a vector in mat-file
                %determine frequency
                ms1 = strrep(name,'Mock_feedback_','');
                ms2 = strrep(ms1,'Hz','');
                self.fb_frequency = str2double(ms2);
                %load mock_feedback
                load(strcat(pathname,'\',fname));
                self.fb_source = mock_feedback_vector;
                
            else %complete *bin file
                if nargin < 3
                    [pathname,name1,name2] = fileparts(fname);
                    fname = strcat(name1,name2);
                end
                df = fopen(strcat(pathname,'\',fname),'r','n','US-ASCII');
                data_sz = fread(df,2,'int');
                all_data = fread(df,data_sz','double');
                if exist(strcat(pathname,'/','exp_info.hdr'),'file')
                    hf = fopen(strcat(pathname,'/','exp_info.hdr'),'r');
                    s = fscanf(hf,'%c');
                    headers = strsplit(s,',');
                    idx = strfind(headers,'Fb values');
                    Index = find(not(cellfun('isempty', idx)));
                    fclose(hf);
                    if isempty(Index) || Index > data_sz(2)
                        button = questdlg('The header file does not contain index of Fb values. Select another file or enter the index of Fb values manually?','Header could not be read','Select file','Enter the index','Select file');
                        switch button
                            case 'Select file'
                                [fname, pathname, index] = uigetfile('*.bin'); %#ok<ASGLU>
                                self.ReadMockFbFile(fname,pathname);
                                return
                            case 'Enter the index'
                                Index = 0;
                                while Index < 1 || Index > data_sz(2)
                                    dialog = inputdlg('Enter the index');
                                    Index = str2double(dialog);
                                end
                                
                                
                        end
                    end
                    
                else
                    double_ans = 0;
                    answer = {};
                    while double_ans < 1 || double_ans > data_sz(2) || isempty(answer)
                        answer = inputdlg(['The header file was not found. Enter the index of feedback values in ' fname]);
                        if ~isempty(answer)
                        double_ans = str2double(answer);
                        end
                    end
                end
                
                self.fb_source = all_data(:,Index);
                %determine file frequency
                [a,b,c] = fileparts(fname); %#ok<ASGLU>
                s = strsplit(b);
                duration = str2double(s{end});
                self.fb_frequency = round(data_sz(1)/duration);
                fclose(df);
            end
        end
    end
        
    
end

