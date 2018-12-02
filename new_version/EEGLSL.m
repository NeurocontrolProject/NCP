classdef EEGLSL < handle

    properties
        %%%%%%%%%%%%%%%%%%%%%% plot & user interface related members %%%%%%%%%%
        %%figures
        fig_interface %settings
        raw_and_ds_figure %plots
        fig_feedback %fb
        %%settings
        plot_length %sec
        plot_size %samples
        plot_refresh_rate %sec
        fb_refresh_rate %sec
        %%plots and axes
        %%raw eeg subplot
        raw_subplot
        raw_plot
        raw_shift
        r_ytick_labels
        raw_ydata_scale
        raw_line %text
        raw_plot_min
        raw_plot_max
        raw_plot_shift
        raw_fit_plot
        %%derived_signals subplot
        ds_subplot
        ds_shift
        ds_plot
        ds_ytick_labels
        ds_ydata_scale
        ds_line
        ds_plot_min
        ds_plot_max
        ds_plot_shift
        ds_fit_plot
        %%feedback subplot
        fbplot_handle %bar
        feedback_axis_handle
        fb_stub %text
        show_fb %bool
        fb_type %string
        
        %%uicontrol
        connect_button
        disconnect_button
        curr_protocol_text
        sn_to_fb_dropmenu
        sn_to_fb_string
        y_limit %fb plot
        status_text
        status_field
        log_text
        add_notes_window
        add_notes_field
        write_notes %pushbutton
        raw_scale_slider
        ds_scale_slider
        montage_fname
        montage_fname_text
        %%data
        channel_labels
        %%%%%%%%%%%% LSL and data input related objects %%%%%%
        streams
        inlet
        data_receive_rate
        path_text
        settings_file
        settings_file_text
        nd %temporarily stores new data
        %%%%%%%%%%%%%%%%%%%%% Data info %%%%%%%%%%%%%%%%%%%%%%
        sampling_frequency
        channel_count
        max_ch_count
        %%%%%%%%%%%%%%%%%%%%% Timers and callbacks %%%%%%%%%%%
        timer_new_data
        timer_disp
        timer_fb
        timer_bt
        
        timer_new_data_function
        timer_disp_function
        timer_fb_function
        timer_bt_function
        
        bt_refresh_rate
        %%%%%%%%%%%%%%%%%%%% Status members
        connected
        recording
        finished
        raw_ylabels_fixed
        ds_ylabels_fixed
        yscales_fixed
        raw_yscale_fixed
        ds_yscale_fixed
        fb_statistics_set
        %%%%%% Signal processing and feedback related members%
        composite_montage %used_ch by used_ch matrix
        allxall% all ch by all ch matrix
        signals %parameters
        derived_signals
        feedback_protocols
        feedback_manager
        current_protocol
        next_protocol
        protocol_sequence
        protocol_types
        sample_size
        samples_acquired
        signal_to_feedback
        used_ch
        last_to_fb
        to_proceed
        count
        to_fb
        %%%%%% subject data management related
        subject_record
        path
        exp_data_length
        %other
        tstop
        sizes
        window %counts fb windows
        default_window_size
        buffer_length
        
        ssd %if an ssd protocol exists
        program_path
        subjects_dropmenu
        edit_protocols_button
        protocol_duration_text
        exp_design
        fb_manager_set
        protocol_indices
        fb_sigmas
        from_file
        fnames
        files_pathname
        looped
        run_protocols
        settings
        bad_channels
        raw_data_indices
        paused
        current_window_size
        init_band
        csp_settings
        bluetooth_connections
        fb_bar_source_set
        fb_color_source_set
        bar_color
        rects
        add_ds_button
        upd_stats_info
        ds_dropmenu_set
        bluetooth_connection
        bluetooth_connect_button
        bt_connected
        signals_to_bt
        %color_fb
        log_text_axes
        
        receive_timing
        fb_timing
        plot_timing
        chunk_sizes
        queue_size
        
        discrete_feedback %array
        discrete_feedback_count %array of ints (one int per protocol)
        cumulative_feedback_count %throughout all the study
        cumulative_mock_feedback_count
        common_feedback_count %mock and real
        common_feedback_rectangle %mock and real
        show_fb_count
        show_fb_rect
        vals
        fb_count %text field
        fb_count_rectangle %rect
        fb_manager_size %const
        hardware_sampling_frequency
        downsampling_ratio
        predicate
        value
        fb_lsl_output
        mock_feedback_index
        recorded
        baseline_window
        baseline_protocol
        time_sum_fb_table
        feedback_comparison_frequency %how often comparison is made
        chunks_per_cell %for fb_spikes recording
        mock_feedback_value
        %%%double blind
        double_blind %bool
        displayed_feedback %'mock' or 'real'
        continue_field
        lambda_min
        lambda_max
        lambda
        csp_chs
        
        show_two_bars %bool
        two_bars_figure
        bar1
        bar2
        bars %handles
        two_bars_set_button
        two_bars_signals
        bar1_data
        bar2_data
        left_bar %subplot
        right_bar %subplot
        two_bars_protocol %num
        feedback_type
        lda_threshold
        tstart
        
        
    end
    
    methods
        % коструктор
        function self = EEGLSL(self) %#ok<INUSD>
            
            
            
            
            self.plot_length = 4;
            self.sampling_frequency = -1;
            self.streams = {};
            self.plot_refresh_rate = 0.2;
            self.data_receive_rate = 0.005;
            self.fb_refresh_rate = 0.05;
            self.bt_refresh_rate = 0.05;
            self.show_fb = 1;
            
            self.max_ch_count = -1; % -1 to get all the channels
            self.connected = false;
            self.fig_feedback = figure('Visible', 'off','Tag','feedback_figure','Menubar','none');
            self.channel_labels = {};
            
            self.current_protocol = 0;
            self.feedback_protocols = {};
            self.exp_data_length = 0;
            self.samples_acquired = 0;
            
            self.subject_record = SubjectRecord;
            [self.program_path, ~, ~] = fileparts(which(mfilename));
            self.path = strcat(self.program_path,'\results');
            self.signal_to_feedback = 2; %the first signal is raw
            
            self.settings_file_text = 'LeftVsRightMu.nss.xml';
            self.settings_file =  'settings\bars_pilot — копия.xml';
            self.recording = 0;
            self.next_protocol = 1;
            self.finished = 0;
            self.raw_ylabels_fixed = 0;
            self.ds_ylabels_fixed = 0;
            self.yscales_fixed = 0;
            self.fb_statistics_set = 0;
            self.raw_ydata_scale = 1000;
            self.ds_ydata_scale = 1000;
            self.nd = [];
            
            
            self.samples_acquired = 0;
            %self.montage_fname = 'C:\Users\user1\AppData\Local\MCS\NeoRec\nvx136.nvx136.monopolar-Pz';
            self.montage_fname = 'D:\neurofeedback\settings\nvx136.nvx136.monopolar-Pz.xml';
            self.montage_fname_text = 'nvx136.nvx136.monopolar-Pz';
            self.raw_shift = 1;
            self.ds_shift = 1;
            %self.sizes = [0]; %#ok<NBRAK>
            self.window = 0;
            self.fb_type = 'Color';
            self.default_window_size = 0;
            self.buffer_length = 0;
            self.ssd = 0;
            self.raw_yscale_fixed = 0;
            self.fb_manager_set = 0;
            self.protocol_indices = 0;
            self.fb_sigmas = 8;
            self.y_limit = [-1 self.fb_sigmas-1];
            self.from_file = 0;
            
            self.settings = struct();
            self.settings.subject = 'Null';
            self.settings.montage_fname = 'D:\neurofeedback\settings\nvx136.nvx136.monopolar-Pz.xml';
            self.settings.settings_file =  'settings\LeftVsRightMu.nss.xml';
            self.bad_channels = {};
            self.raw_data_indices = [];
            self.paused = 0;
            self.init_band = [8 16];
            self.fb_bar_source_set = 0;
            self.fb_color_source_set = 0;
            self.bar_color = [1 0 0];
            self.rects = [];
            self.upd_stats_info = struct();
            self.ds_dropmenu_set = 0;
            self.bluetooth_connection = [];
            self.bt_connected = 0;
            self.signals_to_bt = [0 0];
            self.fb_timing = [];
            self.receive_timing = [];
            self.plot_timing = [];
            self.chunk_sizes = [];
            self.queue_size = [];
            self.discrete_feedback_count = 0;
            self.cumulative_feedback_count = 0;
            self.vals = [];
            
            %             self.timer_new_data_function = @self.TestTiming;
            %             self.timer_disp_function = '';
            %             self.timer_fb_function ='';
            self.timer_new_data_function = @self.Receive;
            self.timer_disp_function = @self.PlotEEGData;
            self.timer_fb_function = @self.RefreshFB;
            self.timer_bt_function = @self.TransmitToBluetooth;
            
            
            
            self.fb_manager_size = 7;
            self.downsampling_ratio = 1;
            self.fb_lsl_output = [];
            self.mock_feedback_index = 0;
            self.recorded = 0;
            self.feedback_comparison_frequency = 0.1; %every n seconds
            self.cumulative_mock_feedback_count = 0;
            self.common_feedback_count = 0;
            
            
            
            self.lambda_min = 0;
            self.lambda_max = 10;
            self.lambda = 0.1;
            self.show_two_bars = 0;
            self.two_bars_signals = [0 0];
            self.two_bars_figure = figure('Visible','off','Menubar','none');
            self.sample_size = 0;
            self.feedback_type = 0; %plain; 1 - LDA
            self.lda_threshold = 0;
            self.csp_chs = {};
        end
        % 
        function UpdateFeedbackSignal(self)
            if length(self.derived_signals) > 1 %%once we created some derived signals
                if ~self.fb_manager_set
                    self.feedback_manager.average = zeros(1,length(self.derived_signals)-1);
                    self.feedback_manager.standard_deviation = ones(1,length(self.derived_signals)-1);
                    self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
                    self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
                    self.fb_manager_set=1;
                end
                
                
                %get data, get avg and std and calculate the feedback
                for s = 2:length(self.derived_signals)
                    dat = self.derived_signals{s}.ring_buff.raw(self.derived_signals{s}.ring_buff.lst-self.current_window_size+1:self.derived_signals{s}.ring_buff.lst);
                    avg  = self.feedback_manager.average(s-1);
                    sdev = self.feedback_manager.standard_deviation(s-1);
                    
                    if strcmpi(self.derived_signals{s}.signal_type,'composite')
                        % since the abs values have been already taken while calculating
                        % fb for each of the dss in the composite ds
                        val = mean(dat);
                    elseif strcmpi(self.derived_signals{s}.signal_type,'combined')
                        % since the abs values have been already taken while summarizing
                        % several combined signals
                        val = mean(dat); 
                    else
                        
                        val = mean(abs(dat));
                    end
                    self.feedback_manager.feedback_vector(s-1)  = (val-avg)/sdev;
                    
                end
                
                %record the feedback
                if self.recording
                    try
                        fb = zeros(self.sample_size/self.downsampling_ratio,self.fb_manager_size);
                        self.window = self.window + 1;
                        %calculate info about feedback
                        fb(:,1) = self.signal_to_feedback-1; %index of feedbacked signal
                        fb(:,2) = self.feedback_manager.feedback_vector(self.signal_to_feedback-1); %feedback itself
                        fb(:,3) = self.feedback_manager.average(self.signal_to_feedback-1); %average relative which the feedback is calculated
                        fb(:,4) = self.feedback_manager.standard_deviation(self.signal_to_feedback-1); %std relatively which the feedback is calculated
                        try
                            if self.current_protocol <= length(self.feedback_manager.window_size)
                                fb(:,5) = self.feedback_manager.window_size(self.current_protocol); %window size if special
                            else
                                fb(:,5) = self.default_window_size;
                            end
                        catch
                            'An error occured while accessing self.feedback_manager.window_size, function UpdateFeedbackSignal' %#ok<NOPRT>
                        end
                        fb(:,6) = self.window;% number of window since recording started
                        
                        
                        %calculate real feedback
                        if self.feedback_manager.feedback_vector(self.signal_to_feedback-1) > self.feedback_protocols{self.current_protocol}.threshold
                            fb(:,7) = 1;
                            if self.feedback_manager.feedback_records.raw(self.feedback_manager.feedback_records.lst,7) == 0 && self.current_protocol
                                self.discrete_feedback_count(self.current_protocol) =  self.discrete_feedback_count(self.current_protocol) + 1;
                                %self.cumulative_feedback_count = self.cumulative_feedback_count + 1;
                                %%%%%calculate number of cell of time-protocol table
                                cell = ceil(self.feedback_protocols{self.current_protocol}.actual_protocol_size/(self.feedback_protocols{self.current_protocol}.protocol_size/self.feedback_protocols{self.current_protocol}.protocol_duration))+1;
                                self.time_sum_fb_table(cell,self.current_protocol) = self.discrete_feedback_count(self.current_protocol);
                                %%%%% if 'real' is displayed
                                if strcmp(self.displayed_feedback,'real') && ~isempty(strfind(lower(self.feedback_protocols{self.current_protocol}.fb_type),'color'))
                                    self.common_feedback_count = self.common_feedback_count + 1;
                                else
                                    fb(:,7) = 0;
                                end %
                            end
                        else
                            fb(:,7) = 0;
                        end
                    catch
                        491 %#ok<NOPRT>
                    end
                    
                    
                    %%%%% calculate mock peak if 'mock' is displayed
                    if strcmp(self.displayed_feedback,'mock') || strcmp(self.feedback_protocols{self.current_protocol}.fb_type,'mock') && self.mock_feedback_index
                        if self.feedback_protocols{self.current_protocol}.fb_source(self.mock_feedback_index) > self.feedback_protocols{self.current_protocol}.threshold
                            self.feedback_protocols{self.current_protocol}.discrete_mock_fb(self.mock_feedback_index) = 1;
                            if self.feedback_protocols{self.current_protocol}.discrete_mock_fb(self.mock_feedback_index-1) == 0
                                %self.cumulative_mock_feedback_count = self.cumulative_mock_feedback_count +1;
                                self.common_feedback_count = self.common_feedback_count + 1;
                            end
                        elseif self.mock_feedback_index
                            self.feedback_protocols{self.current_protocol}.discrete_mock_fb(self.mock_feedback_index) = 0;
                        end
                    end
                    
                    
                    %display the rectangle and the counter
                    if self.show_fb_rect &&  self.common_feedback_count
                        self.common_feedback_rectangle.Position(4) = log10(self.common_feedback_count)/6 + 0.01;
                    elseif self.show_fb_rect
                        self.common_feedback_rectangle.Position(4) = 0.01;
                    end
                    
                    if self.show_fb_count
                        self.fb_count.String = num2str(self.common_feedback_count);
                    end
                    
                    
                    
                    
                    %save discrete feedback
                    self.discrete_feedback{self.current_protocol} = [self.discrete_feedback{self.current_protocol} fb(:,7)'];
                    
                    
                    %saving records
                    self.feedback_manager.feedback_records.append(fb);
                    %saved
                end
            end
        end
        % считает среднее и СКО для буфера (какой то части сигнала) и запись их в файл 
        function Update_Statistics(self)
            if(self.current_protocol>0 && self.current_protocol <= length(self.feedback_protocols))
                % fetches the data from all derived_signals except raw and
                % calculates their statistics
                % though why do it if we need stats of feedback values, not of the
                % 'raw' derived signals
                self.upd_stats_info.protocol = self.current_protocol;
                N = self.feedback_protocols{self.current_protocol}.actual_protocol_size;
                if(N>0) && length(self.derived_signals) > 1
                    head_str = 'N, protocol_name, protocol_show_as'; %what we are going to write to file
                    st = [num2str(self.current_protocol) ' ' self.feedback_protocols{self.current_protocol}.protocol_name ' ' self.feedback_protocols{self.current_protocol}.show_as];
                    for s = 2:length(self.derived_signals)
                        if self.derived_signals{s}.collect_buff.lst - N+1 < self.derived_signals{s}.collect_buff.fst
                            values = self.derived_signals{s}.collect_buff.raw(self.derived_signals{s}.collect_buff.fst:self.derived_signals{s}.collect_buff.lst,:);
                            self.derived_signals{s}.upd_stats_idc(1) = self.derived_signals{s}.collect_buff.fst;
                            self.derived_signals{s}.upd_stats_idc(2) = self.derived_signals{s}.collect_buff.lst;
                        else
                            values = self.derived_signals{s}.collect_buff.raw(self.derived_signals{s}.collect_buff.lst - N+1:self.derived_signals{s}.collect_buff.lst,:);
                            self.derived_signals{s}.upd_stats_idc(1) = self.derived_signals{s}.collect_buff.lst - N+1;
                            self.derived_signals{s}.upd_stats_idc(2) = self.derived_signals{s}.collect_buff.lst;
                        end
                        %if isempty(self.derived_signals{s}.statvalues)
                        self.derived_signals{s}.statvalues = values;
                        if strcmp(self.derived_signals{s}.signal_type,'combined')
                            
                            %end
                            try
                                
                                self.feedback_manager.average(s-1) = mean(sum(abs(values),2));
                                self.feedback_manager.standard_deviation(s-1) = std(sum(abs(values),2));
                            catch
                                587 %#ok<NOPRT>
                            end
                        elseif strcmp(self.derived_signals{s}.signal_type,'composite')
                            self.feedback_manager.average(s-1) = mean(values);
                            self.feedback_manager.standard_deviation(s-1) = std(values);
                        else
                            %end
                            self.feedback_manager.average(s-1) = mean(abs(values));
                            self.feedback_manager.standard_deviation(s-1) = std(abs(values));
                        end
                        self.baseline_window = self.current_window_size;
                        head_str = [head_str ', ' self.derived_signals{s}.signal_name ' av, ' self.derived_signals{s}.signal_name ' std'];
                        st = [st ' ' num2str(mean(abs(values))) ' ' num2str(std(abs(values)))];
                    end
                    self.fb_statistics_set = 1;
                    self.yscales_fixed = 1;
                    self.raw_yscale_fixed = 1;
                    self.ds_yscale_fixed = 1;
                    %%% write  the results to file
                    curr_date = datestr(date,29);
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name));
                    end
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
                    end
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
                    end
                    
                    filename = strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',...
                        self.subject_record.time_start,'\','Update_Stats.txt');
                    if ~exist(filename,'file')
                        f = fopen(filename,'w');
                        fprintf(f, head_str);
                        fprintf(f,'\n');
                    else
                        f = fopen(filename,'a');
                    end
                    st = [st '\n'];
                    fprintf(f,st);
                    fclose(f);
                end;
                
            end
            
            
        end
        % получает данные из потока и обрабатывает их
        function Receive(self,timer_obj, event) %#ok<INUSD>
            rt  = tic;
            if self.current_protocol
                %set start and end indices
                for ds = 1:length(self.derived_signals)
                    %start
                    if size(self.protocol_indices,2) < ds*2 || isnan(self.protocol_indices(self.current_protocol,2*(ds-1)+1)) || ~self.feedback_protocols{self.current_protocol}.actual_protocol_size
                        %mark the start of the protocol
                        self.protocol_indices(self.current_protocol,2*(ds-1)+1) = self.derived_signals{ds}.collect_buff.lst - self.derived_signals{ds}.collect_buff.fst +1;
                    end
                    % mark the end
                    self.protocol_indices(self.current_protocol,2*(ds-1)+2) = self.derived_signals{ds}.collect_buff.lst -self.derived_signals{ds}.collect_buff.fst +1;
                end
                % show current protocol in red in the main window
                if self.recording
                    self.log_text.String{self.current_protocol+1} = strcat('\color{red}',self.feedback_protocols{self.current_protocol}.show_as);
                end
            end
            %receive and process the data
            try
                [sample, timestamp] = self.inlet.pull_chunk(); %#ok<ASGLU>
            catch err
                %if the stream has been lost
                if strcmp(err.identifier,'lsl:lost_error')
                    %recover the stream
                    if ~isempty(self.streams)
                        stop(self.timer_new_data);
                        self.timer_new_data.Period = 5; %recover the streams every 5 seconds
                        self.timer_new_data.ExecutionMode = 'fixedSpacing';
                        start(self.timer_new_data);
                        self.streams = [];
                        if self.current_protocol
                            self.log_text.String{self.current_protocol+1} = strcat('\color{gray}',self.feedback_protocols{self.current_protocol}.show_as);
                            self.feedback_protocols{self.current_protocol}.actual_protocol_size = 0;
                            self.next_protocol = self.current_protocol;
                            self.current_protocol = 0;
                            self.recording = 0;
                            set(self.connect_button, 'Callback', @self.StartRecording);
                            set(self.connect_button, 'String', 'Start recording');
                            set(self.connect_button,'Enable','off');
                            
                        end
                    end
                    %try to recover the stream
                    lsllib = lsl_loadlib();
                    self.streams = lsl_resolve_byprop(lsllib, self.predicate,self.value,1,1);%found
                    if ~isempty(self.streams)
                        self.inlet = lsl_inlet(self.streams{1});
                        stop(self.timer_new_data);
                        self.timer_new_data.Period = self.data_receive_rate; %reset the timer
                        self.timer_new_data.ExecutionMode = 'fixedRate';
                        start(self.timer_new_data);
                        set(self.connect_button,'Enable','on');
                    end
                    return
                end
                
            end
            
            self.chunk_sizes(end+1) = size(sample,2);
            try
                self.nd = [self.nd sample];
            catch
                size(sample)
            end
            
            %downsample && apply
            if size(self.nd,2) >= self.sample_size
                %if size(self.nd,2) >= 6*self.downsampling_ratio
                
                sample_to_apply = self.nd(:,1:self.sample_size);
                %sample_to_apply = self.nd;
                
                self.nd = self.nd(:,self.sample_size+1:end);
                sample_to_apply = downsample(sample_to_apply',self.downsampling_ratio)';
                %self.nd = [];
                sz = size(sample_to_apply,2); % downsampled fs
                for ds = 1:length(self.derived_signals)
                    self.derived_signals{ds}.Apply(sample_to_apply,self.recording);
                end
                self.samples_acquired = self.samples_acquired+sz;
                
                try
                    self.UpdateFeedbackSignal;
                catch
                    'Error while updating Feedback' %#ok<NOPRT>
                end
                
                %if recording
                if(self.current_protocol>0 && self.current_protocol <= length(self.feedback_protocols))
                    %self.feedback_protocols{self.current_protocol}.actual_protocol_size = self.feedback_protocols{self.current_protocol}.actual_protocol_size +self.current_window_size;
                    self.feedback_protocols{self.current_protocol}.actual_protocol_size = self.feedback_protocols{self.current_protocol}.actual_protocol_size +sz;
                    %if current_protocol has finished
                    if self.feedback_protocols{self.current_protocol}.actual_protocol_size >= self.feedback_protocols{self.current_protocol}.protocol_size
                        for ds = 1:length(self.derived_signals)
                            self.protocol_indices(self.current_protocol,2*(ds-1)+2) = self.derived_signals{ds}.collect_buff.lst -self.derived_signals{ds}.collect_buff.fst +1;
                        end
                        %csp and update_stats
                        try
                            %if csp or ssd
                            if self.current_protocol == self.ssd
                                %self.PrepareLearning;
                                self.Prepare_CSP();
                            % if to update stats and not csp nor ssd (because csp updates stats)
                            elseif self.feedback_protocols{self.current_protocol}.to_update_statistics && isempty(strfind(lower(self.feedback_protocols{self.current_protocol}.protocol_name),'csp'))
                                self.Update_Statistics();
                            end
                            if self.current_protocol
                                self.log_text.String{self.current_protocol+1} = strcat('\color{black}',self.feedback_protocols{self.current_protocol}.show_as);
                            end
                            
                        catch
                            575%#ok<NOPRT>
                        end
                        
                        %make it visible
                        try
                            if self.feedback_protocols{self.current_protocol}.stop_after
                                set(self.connect_button, 'String', 'Start recording');
                                set(self.connect_button, 'Callback',@self.StartRecording);%%%%%
                                self.StopRecording();
                            else
                                self.StartRecording();
%                                 self.current_protocol = self.next_protocol;
%                                 self.next_protocol = self.next_protocol + 1;
                                
                                if self.current_protocol > length(self.feedback_protocols)
                                    if self.looped
                                        self.current_protocol = 1;
                                        self.next_protocol = 2;
                                        for pr = 1:length(self.feedback_protocols)
                                            self.feedback_protocols{pr}.actual_protocol_size = 0;
                                        end
                                    else
                                        self.StopRecording();
                                    end
                                end
                            end
                            
                        catch
                            602 %#ok<NOPRT>
                        end
                        %set fb
                        self.SetFBWindow;
                    end
                    %the following line is needed to maintain several csps
                    waitfor(findobj('Tag','heads_figure'));
                    
                    %start receiving
                    if strcmp(self.timer_new_data.Running,'off')
                        self.inlet = lsl_inlet(self.streams{1});
                        self.InitTimer();
                    end
                end
                
            end;
            self.queue_size(end+1) = size(self.nd,2);
            self.receive_timing(end+1) = toc(rt);
        end
        % подключается к lsl - потоку и получает данные о нем.
        function Connect(self,predicate, value)
            
            self.predicate = predicate;
            self.value = value;
            if self.from_file && any([~isempty(self.fnames),~isempty(self.files_pathname)])
                RecordedStudyToLSL(self.fnames,self.files_pathname,self.looped,self.sampling_frequency);
            elseif self.from_file
                warning('No files selected')
                return;
            end
            lsllib = lsl_loadlib();
            disp('Connecting...')
            fl = 1;
            while fl<5
                self.streams = lsl_resolve_byprop(lsllib, self.predicate,self.value);%found
                if ~isempty(self.streams)
                    break;
                end
                disp(strcat('Streams were not found yet, attempt ', num2str(fl), '/', num2str(5)) )
                pause(0.5);
                fl = fl+1;
            end
            
            if fl == 5 && isempty(self.streams)
                %                      disp('Please make sure that the hardware is plugged and software running.'
                %                      'Or try to change pair "predicate/value" and re-run the script')
                %                 end
                in = questdlg('Select the source ','Choose the source', 'Hardware', 'File','File');
                switch in
                    case 'Hardware'
                        disp('Please make sure that the hardware is plugged and software running./nOr try to change pair "predicate/value" and re-run the script')
                        self.RunInterface(predicate,value);
                    case 'File'
                        self.from_file = 1;                        
                        self.RunInterface(predicate,value);
                        %                         while isempty(self.streams)
                        %                             self.streams = lsl_resolve_byprop(lsllib,predicate, value);%found
                        %                         end
                end
            end
            disp('Connected')
            if length(self.streams) > 1
                warning('The pair predicate/value matches more than one channel. The results might be inconsistent. You might want to restart MATLAB');
            end
            
            self.hardware_sampling_frequency = self.streams{1}.nominal_srate();
            if self.hardware_sampling_frequency > 1000  && ~mod(self.hardware_sampling_frequency,1000)
                self.sampling_frequency = 1000;
                self.downsampling_ratio = self.hardware_sampling_frequency/1000;
            elseif self.hardware_sampling_frequency > 1000 && mod(self.hardware_sampling_frequency,1000)
                disp('Sampling frequency is not a multiple of 1000, downsampling is not available')
                self.sampling_frequency = self.hardware_sampling_frequency;
            elseif self.hardware_sampling_frequency <= 1000
                self.sampling_frequency = self.hardware_sampling_frequency;
            end
            
            %calculate sample_size (to filter) before downsampling
            if fix(self.hardware_sampling_frequency * self.fb_refresh_rate) > 6*self.downsampling_ratio
                self.sample_size = fix(self.hardware_sampling_frequency * self.fb_refresh_rate);
            else
                self.sample_size = 6*self.downsampling_ratio;
            end
            
            
            self.inlet = lsl_inlet(self.streams{1});
            if exist(strcat(self.program_path,'\','channels.txt'), 'file')
                delete(strcat(self.program_path,'\','channels.txt'))
            end
            
            disp('Trying to read the channels... ');
            cd(self.program_path);
            if strcmp(self.streams{1}.name,'File')
                winopen('channels_shcut.lnk') %%channels_shcut contain 'type' and 'Data' in 'object' field
                % change it to obtain channels from another source
                while ~exist('channels.txt','file')
                    pause(0.01)
                end
                self.channel_labels = read_channel_file('channels.txt');
                
            else
                command = ['resolve_channels8.exe' ' ' predicate ' ' value];
                status = system(command);
                if ~status
                    self.channel_labels = read_channel_file('channels.txt');
                end
            end
            %self.channel_labels = {};
            
            if isempty(self.channel_labels)
                if exist('CurrentChannelLabels.mat','file')
                    warning('The channel labels were not resolved from the stream. Loading them from CurrentChannelLabels.mat')
                    load CurrentChannelLabels.mat
                    if exist('channels','var')
                        self.channel_labels = channels;
                    else
                        warning('CurrentChannelLabels.mat does not contain information about channels. Exiting the program')
                    end
                else
                    warning('The channel labels were not resolved from the stream. CurrentChannelLabels.mat is not found.Exiting the program')
                end                
            end
            if isempty(self.channel_labels)
                return
            end
            %channels = derive_channel_labels(self.streams{1});

            self.plot_size = self.plot_length * self.sampling_frequency;
            
            %%set durations and window size based on sampling frequency
            for pr = 1:length(self.feedback_protocols)
                self.feedback_protocols{pr}.Recalculate(self.sampling_frequency,self.fb_refresh_rate);
            end
            self.discrete_feedback_count = zeros(1,length(self.feedback_protocols));
            self.discrete_feedback = cell(1,length(self.feedback_protocols));
            
            % get if protocols contain csp
            if ~self.from_file
                for pr = 1:length(self.feedback_protocols)
                    if any([strfind(lower(self.feedback_protocols{pr}.protocol_name),'ssd'), strfind(lower(self.feedback_protocols{pr}.protocol_name),'csp')]);
                        self.ssd = pr;
                    end
                    
                    try 
                        if self.feedback_protocols{pr}.window_size
                            self.feedback_manager.window_size(pr) = self.feedback_protocols{pr}.window_size;
                        end
                    catch
                        941 %#ok<NOPRT>
                    end
                end
            end
            max_pr_duration = 0;
            
            %get expected data length
            for j = 1:length(self.feedback_protocols)
                self.exp_data_length = self.exp_data_length + self.feedback_protocols{j}.protocol_size;
                if self.feedback_protocols{j}.protocol_duration > max_pr_duration
                    max_pr_duration = self.feedback_protocols{j}.protocol_duration;
                end
            end
            
            self.exp_data_length = fix(self.exp_data_length * 1.5); %just in case
            self.time_sum_fb_table = NaN(max_pr_duration/self.feedback_comparison_frequency,length(self.feedback_protocols));
            for i = 1:length(self.feedback_manager.window_size)
                if self.feedback_manager.window_size(i) <=5
                    warning('Given that the sampling frequency is %d ,the window length of protocol %s is less than 6 samples. Set the window size at least %d ms', self.sampling_frequency,self.feedback_protocols{i}.protocol_name, (5000/self.sampling_frequency+1))
                end
                if self.feedback_manager.window_size(i)/self.sampling_frequency <= self.data_receive_rate
                    warning('The window size of protocol %s is too small. Increase the window size or decrease data receive rate', self.feedback_protocols{i}.protocol_name)
                end
            end
            %set ds
            if self.from_file
                
                if self.ssd
                    self.derived_signals{1} = self.CreateNewDS('Raw',ones(length(self.channel_labels),1));
                else
                    for i = 1: length(self.signals)
                        
                        self.derived_signals{i} = DerivedSignal(1,self.signals{i}, self.sampling_frequency,self.exp_data_length,self.channel_labels,self.plot_length);
                        
                        self.derived_signals{i}.UpdateSpatialFilter(self.signals{i}.channels,self.derived_signals{1},self.bad_channels);
                        if ~isempty(self.signals{i}.filters)
                            self.derived_signals{i}.UpdateTemporalFilter(size(self.signals{i}.channels,2)-1,self.signals{i}.filters.range,self.signals{i}.filters.order,self.signals{i}.filters.mode);
                        end
                        if i > 1 && isfield(self.signals{i},'fAverage')
                            if ~isempty(self.signals{i}.fAverage)
                                self.feedback_manager.average(i-1) = self.signals{i}.fAverage;
                                self.self.derived_signals{i}.file_av = self.signals{i}.fAverage;
                                self.fb_manager_set = 1;
                            else
                                self.feedback_manager.average(i-1) = 0;
                                self.fb_manager_set = 0;
                            end
                            if ~isempty(self.signals{i}.fStdDev)
                                self.feedback_manager.standard_deviation(i-1) = self.signals{i}.fStdDev;
                                self.self.derived_signals{i}.file_std = self.signals{i}.fStdDev;
                                self.fb_manager_set = 1;
                            else
                                self.feedback_manager.standard_deviation(i-1) =1;
                                self.fb_manager_set = 0;
                            end
                            
                            self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
                            self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
                        end
                    end
                end
                %self.derived_signals{1} = DerivedSignal(1,dummy_signal, self.sampling_frequency,self.exp_data_length,self.channel_labels,self.plot_length);
                %self.derived_signals{1}.UpdateSpatialFilter(ones(length(self.channel_labels),1),self.channel_labels);
            else
                if self.ssd
                    % if ssd or csp - remove all derived_signals except raw
                    self.derived_signals = cell(1,1);
                else
                    self.derived_signals = cell(1,length(self.signals));
                end
                for i = 1: length(self.derived_signals)
                    
                    self.derived_signals{i} = DerivedSignal(1,self.signals{i}, self.sampling_frequency,self.exp_data_length,self.channel_labels,self.plot_length);
                    
                    self.derived_signals{i}.UpdateSpatialFilter(self.signals{i}.channels,self.derived_signals{1},self.bad_channels);
                    if ~isempty(self.signals{i}.filters)
                        self.derived_signals{i}.UpdateTemporalFilter(size(self.signals{i}.channels,2)-1,self.signals{i}.filters(1).range,self.signals{i}.filters(1).order,self.signals{i}.filters(1).mode);
                    end
                    if ~isempty(self.signals{i}.sType)
                        self.derived_signals{i}.signal_type = self.signals{i}.sType;
                    end
                    if i > 1 && isfield(self.signals{i},'fAverage')
                        if ~isempty(self.signals{i}.fAverage)
                            self.feedback_manager.average(i-1) = self.signals{i}.fAverage;
                            self.derived_signals{i}.file_av = self.signals{i}.fAverage;
                            self.fb_manager_set = 1;
                        else
                            self.feedback_manager.average(i-1) = 0;
                            self.fb_manager_set = 0;
                        end
                        if ~isempty(self.signals{i}.fStdDev)
                            self.feedback_manager.standard_deviation(i-1) = self.signals{i}.fStdDev;
                            self.derived_signals{i}.file_std = self.signals{i}.fStdDev;
                            self.fb_manager_set = 1;
                        else
                            self.feedback_manager.standard_deviation(i-1) =1;
                            self.fb_manager_set = 0;
                        end
                        self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
                        self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
                    end
                end
                
            end
            
            %get raw channels
            for ds = 1:length(self.derived_signals)
                if strcmpi(self.derived_signals{ds}.signal_name, 'raw')
                    raw = self.derived_signals{ds};
                    self.used_ch = raw.channels;
                end
            end
            
            
            self.protocol_indices = zeros(length(self.feedback_protocols),length(self.derived_signals)*2);
            self.current_window_size = self.feedback_manager.window_size(1);
            %self.RunInterface;
            if self.from_file
                self.StartRecording();
            end
            %%bluetooth
            %             try
            %                 disp('Establishing bluetooth connection')
            %                 self.bluetooth_connection  = Bluetooth('komod53',1);
            %                 fopen(self.bluetooth_connection);
            %                 self.fb_refresh_rate = 0.001;
            %                 disp('Bluetooth connection established')
            %             catch
            %
            %                 1 %#ok<NOPRT>
            %             end
            %run the timers
            self.tstart = tic;
            if ishandle(self.fig_interface)
                tic
                self.InitTimer();
            end
            
        end
        % запуск таймеров
        function InitTimer(self)
            try
                if strcmp(self.timer_new_data.Running,'off')
                    start(self.timer_new_data);
                end
            catch
                disp('timer new data was not started')
            end
            try
                if strcmp(self.timer_disp.Running,'off')
                    start(self.timer_disp);
                end
            catch
                disp('plotting timer was not started')
            end
            try
                if strcmp(self.timer_fb.Running,'off')
                    start(self.timer_fb);
                end
            catch
                disp('feedback timer was not started')
            end
            
            set(self.connect_button, 'String', 'Start recording');
            set(self.connect_button, 'Callback',@self.StartRecording);
        end
        % запускает интерфейс (отрисовка всех элементов)
        function RunInterface(self,predicate,value)
            %read subjects file
            if exist(strcat(self.program_path,'\subjects.txt'),'file')
                subjects_file = fopen(strcat(self.program_path,'\subjects.txt'));
                subjects = {};
                
                subjects{end+1} = fgetl(subjects_file);
                while ischar(subjects{end})
                    subjects{end+1} = fgetl(subjects_file);
                end
                subjects = subjects(1:end-1);
            else
                subjects = {};
            end
            subjects = [{'Null','Add a new subject'} sort(subjects)];
            if verLessThan('matlab','8.4.0')
                self.fig_interface = figure('CloseRequestFcn',@self.DoNothing,'Menubar','none');
            else
                self.fig_interface = figure('NumberTitle','off','Name','Experimental settings','Menubar','none');
                self.fig_interface.CloseRequestFcn = @self.DoNothing;
            end
            
            prr_text = uicontrol('Parent',self.fig_interface, 'Style', 'text', 'String', 'Plot refresh rate, s', 'Position',[20 250 120 30],'HorizontalAlignment','left');
            prr = uicontrol('Parent', self.fig_interface, 'Style', 'edit', 'String', num2str(self.plot_refresh_rate), 'Position', [125 260 50 20]);
            drr_text = uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', 'Data receive rate, s', 'Position', [20 210 100 30],'HorizontalAlignment','left');
            drr = uicontrol('Parent', self.fig_interface, 'Style', 'edit', 'String', num2str(self.data_receive_rate), 'Position', [125 220 50 20]);
            frr_text = uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', 'Feedback refresh rate, s', 'Position', [20 190 100 30],'HorizontalAlignment','left');
            frr = uicontrol('Parent', self.fig_interface, 'Style', 'edit', 'String', num2str(self.fb_refresh_rate), 'Position', [125 190 50 20]);
            self.path_text =uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', self.path,'Position', [120 125 200 35],'HorizontalAlignment','left');
            path_button = uicontrol('Parent',self.fig_interface,'Style', 'pushbutton', 'String', 'Select path', 'Callback', @self.SetWorkpath, 'Position', [20 135 100 35]);
            self.settings_file_text =uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', self.settings_file,'Position', [120 90 200 35],'HorizontalAlignment','left');
            settings_file_button = uicontrol('Parent',self.fig_interface,'Style', 'pushbutton', 'String', 'Select exp.design', 'Callback', @self.SetDesignFile, 'Position', [20 100 100 35]);
            set_button = uicontrol('Parent',self.fig_interface,'Style', 'pushbutton', 'String', 'Run the experiment', 'Position', [100 20 200 40],'Callback','uiresume','Tag','set_button');
            %montage_file_button = uicontrol('Parent',self.fig_interface,'Style', 'pushbutton', 'String', 'Select exp. montage', 'Callback', @self.SetMontageFile, 'Position', [20 60 100 35]); %#ok<NASGU>
            %self.montage_fname_text = uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', self.montage_fname_text,'Position', [120 60 200 35],'HorizontalAlignment','left');
            show_feedback = uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', 'Show feedback to subject','Position', [20 290 135 20],'HorizontalAlignment','left');
            show_fb_check = uicontrol('Parent', self.fig_interface, 'Style', 'checkbox' ,'Position', [160 295 20 20],'HorizontalAlignment','left','Value',1);
            self.subjects_dropmenu = uicontrol('Parent', self.fig_interface,'Style','popupmenu','Position',[170 320 100 20],'String',subjects,'Callback',@self.SetSubject);
            sn_text = uicontrol('Parent', self.fig_interface, 'Style', 'text', 'String', 'Choose/Enter subject name', 'Position',[20 315 140 20],'HorizontalAlignment','left');
            subj_folder_button = uicontrol('Parent', self.fig_interface,'Style','pushbutton','Position',[285 320 150 20],'String','Or select subject folder','Callback',@self.SetSubjectFolder);
            %show_two_bars_chb = uicontrol('Parent', self.fig_interface,'Style','checkbox','Position',[285 280 150 20],'String','Show two bars','Value',1);
            %%%%%%%%%%%%%%%%%%%%uncomment this if you want to be able to run from file
            %from_file_chb =  uicontrol('Parent', self.fig_interface,'Style','checkbox','Position',[340 273 200 20],'Tag','from_file_chb','String','From file');
            %loop_replay_chb = uicontrol('Parent', self.fig_interface,'Style','checkbox','Position',[340 253 200 20],'Tag','From_file_loop','String','Loop the recording?');
            %use_protocols_chb = uicontrol('Parent', self.fig_interface,'Style','checkbox','Position',[340 233 200 20],'Value',1,'Tag','Protocols from files','String','Use protocols from files?');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            uiwait();
            if ishandle(self.fig_interface) %if the window is not closed
                if verLessThan('matlab','8.4.0')
                    self.plot_refresh_rate = str2double(get(prr,'String'));
                    self.data_receive_rate = str2double(get(drr,'String'));
                    self.fb_refresh_rate = str2double(get(frr,'String'));
                    
                    set(self.fig_interface,'Visible', 'off');
                    self.show_fb = get(show_fb_check, 'Value');
                    self.from_file = get(from_file_chb,'Value');
                    if self.from_file
                        self.looped = get(loop_replay_chb,'Value');
                        self.run_protocols = get(use_protocols_chb,'Value');
                    end
                    
                else
                    self.plot_refresh_rate = str2double(prr.String);
                    self.data_receive_rate = str2double(drr.String);
                    self.fb_refresh_rate = str2double(frr.String);
                    set(self.fig_interface,'Visible','off');
                    self.show_fb = get(show_fb_check,'Value');
                    if exist('from_file_chb','var')
                        self.from_file = get(from_file_chb,'Value');
                    end
                end
                %self.show_two_bars = show_two_bars_chb.Value;
                subjects = [subjects {self.subject_record.subject_name}];
                subjects = sort(unique(subjects));
                subjects_file = fopen(strcat(self.program_path,'\subjects.txt'),'wt');
                
                for s = 1:length(subjects)
                    if ~(strcmp(subjects{s},'Add a new subject')|| strcmp(subjects{s},'Null'))
                        fprintf(subjects_file,'%s\n',subjects{s});
                    end
                end
                fclose(subjects_file);
                
                self.timer_new_data = timer('Name','receive_data','TimerFcn', self.timer_new_data_function,'ExecutionMode','fixedRate',...
                    'Period',self.data_receive_rate);
                self.timer_disp = timer('Name','plot_data','TimerFcn', self.timer_disp_function,'ExecutionMode','fixedRate',...
                    'Period', self.plot_refresh_rate);
                self.timer_fb = timer('Name','refresh_feedback','TimerFcn',self.timer_fb_function,'ExecutionMode','fixedRate',...
                    'Period',self.fb_refresh_rate);
                self.timer_bt = timer('Name','send_bt_bytes','TimerFcn',self.timer_bt_function,'ExecutionMode','fixedRate','Period',self.bt_refresh_rate);
                self.feedback_manager = FeedbackManager;
                if self.from_file
                    predicate = 'name';
                    value = 'File';
                    if exist('loop_replay_chb','var')
                        self.looped = loop_replay_chb.Value;
                    end
                    if exist('use_protocols_chb','var')
                        self.run_protocols = use_protocols_chb.Value;
                    end
                    [self.fnames, self.files_pathname, filterindex] = uigetfile('.bin','Select files to play','MultiSelect','on');
                    if any([ischar(self.fnames), iscell(self.fnames)])
                        %subject_folder = self.streams{1}.source_id;
                        [protocols, protocols_show_as, durations, channels,settings_file] = GetDataProperties(self.files_pathname,self.fnames);
                        self.channel_labels = channels;
                        if self.run_protocols
                            self.settings_file = settings_file;
                            self.protocol_sequence = protocols;
                            self.feedback_protocols = [];
                            nfs = NeurofeedbackSession;
                            nfs.LoadFromFile(self.settings_file);
                            self.protocol_types = nfs.protocol_types;
                            %self.feedback_protocols = nfs.feedback_protocols;
                            self.csp_settings = nfs.csp_settings;
                            self.signals = nfs.derived_signals;
                            self.sampling_frequency = nfs.sampling_frequency;
                            self.double_blind = nfs.double_blind;
                            
                            for pr = 1:length(protocols)
                                
                                self.feedback_protocols{pr} = RealtimeProtocol;
                                
                                self.feedback_protocols{pr}.protocol_name = protocols{pr};
                                self.feedback_protocols{pr}.protocol_duration = durations(pr);
                                if ~isempty(protocols_show_as)
                                    self.feedback_protocols{pr}.show_as = protocols_show_as{pr};
                                else
                                    self.feedback_protocols{pr}.show_as = protocols{pr};
                                end
                                if strfind(lower(protocols{pr}),'ssd')
                                    self.ssd = pr;
                                    self.feedback_protocols{pr}.band = 1;
                                elseif strfind(lower(protocols{pr}),'csp')
                                    self.ssd = pr;
                                    self.feedback_protocols{pr}.band = 1;
                                elseif strcmpi(protocols{pr},'baseline')
                                    self.feedback_protocols{pr}.to_update_statistics = 1;
                                elseif strfind(lower(protocols{pr}),'feedback')
                                    self.feedback_protocols{pr}.fb_type = protocols{pr};
                                end
                                for type = 1:length(self.protocol_types)
                                    if strcmp(self.protocol_types{type}.sProtocolName, self.feedback_protocols{pr}.protocol_name)
                                        self.feedback_protocols{pr}.window_duration = self.protocol_types{type}.nMSecondsPerWindow;
                                        self.feedback_protocols{pr}.to_update_statistics = self.protocol_types{type}.bUpdateStatistics;
                                        try %#ok<TRYNC>
                                            self.feedback_protocols{pr}.band = self.protocol_types{type}.dBand;
                                        end
                                        
                                    end
                                end
                            end
                        end
                    end
                else
                    %self.channel_labels = read_montage_file(self.montage_fname);
                    nfs = NeurofeedbackSession;
                    nfs.LoadFromFile(self.settings_file);
                    self.protocol_types = nfs.protocol_types;
                    self.feedback_protocols = nfs.feedback_protocols;
                    self.double_blind = nfs.double_blind;
                    self.show_fb_count = nfs.show_fb_count;
                    self.show_fb_rect = nfs.show_fb_rect;
                    if self.double_blind
                        if exist(strcat(self.path,'\',self.subject_record.subject_name,'\','fb.bin'),'file')
                            session_selection = figure('Position',[900 500 220 100],'Menubar','none');
                            select = uicontrol('Parent',session_selection,'Style','listbox','String',{'First session','Second and consecutive session'},'Position',[10 40 200 50]);
                            okay_button = uicontrol('Parent',session_selection,'String','OK', 'Position',[85 10 50 20],'Callback','uiresume');
                            uiwait;
                            if select.Value == 2 %the second experiment
                                close(session_selection);
                                try
                                    load(strcat(self.path,'\',self.subject_record.subject_name,'\','fb.bin'),'mock_feedback','-mat');
                                catch
                                    1285 %#ok<NOPRT>
                                    disp('Error loading fb.bin. Using real feedback')
                                    mock_feedback = 0;
                                end
                                if mock_feedback
                                    self.displayed_feedback = 'mock'; %#ok<UNRCH>
                                else
                                    self.displayed_feedback = 'real';
                                end
                            else %the first experiment, random feedback
                                close(session_selection);
                                fb = {'mock','real'};
                                self.displayed_feedback = fb{randi([1 numel(fb)])};
                            end
                            
                        else
                            fb = {'mock','real'};
                            self.displayed_feedback = fb{randi([1 numel(fb)])};
                        end
                    else
                        self.displayed_feedback = 'real';
                        
                    end
                    
                    message = '';
                    fb_source = {};
                    fb_source_set = 0;
                    for pr = 1:length(self.feedback_protocols)
                        if strcmp(self.feedback_protocols{pr}.fb_type,'mock')
                            if exist(self.feedback_protocols{pr}.fbSource,'file')
                                self.feedback_protocols{pr}.ReadMockFbFile(self.feedback_protocols{pr}.fbSource);
                                fb_source{end+1} = self.feedback_protocols{pr}.fbSource;
                                fb_source_set = 1;
                            elseif ~isempty(fb_source) && fb_source_set
                                if strcmpi(fb_source,'real')
                                    self.feedback_protocols{pr}.fb_type = 'Color intensity';
                                    self.feedback_protocols{pr}.protocol_name = 'Feedback_color';
                                    self.feedback_protocols{pr}.show_as = 'Feedback_color';
                                    self.feedback_protocols{pr}.fb_source = 'real';
                                else
                                    self.feedback_protocols{pr}.fbSource = fb_source{mod(pr-self.ssd-1,length(fb_source))+1};
                                    self.feedback_protocols{pr}.ReadMockFbFile(fb_source{mod(pr-self.ssd-1,length(fb_source))+1});
                                    disp([num2str(pr) ' mock feedback source ' self.feedback_protocols{pr}.fbSource])
                                end
                            end
                            if ~fb_source_set
                                
                                if isempty(self.feedback_protocols{pr}.fbSource)
                                    message = 'Mock feedback source is not specified';
                                elseif  ~exist(self.feedback_protocols{pr}.fbSource,'file')
                                    message = 'Mock feedback file cannot be found';
                                end
                                
                                button = questdlg(message,['Mock feedback for ' num2str(pr) ' protocol'],'Select a file', 'Use real feedback','Select a file');
                                switch button
                                    case ''
                                        self.feedback_protocols{pr}.fbSource = 'real';
                                    case 'Select a file'
                                        [fname, pathname, index] = uigetfile('*.bin'); %#ok<ASGLU>
                                        if fname ~= 0
                                            self.feedback_protocols{pr}.ReadMockFbFile(fname,pathname);
                                            fb_source{end+1} = strcat(pathname,fname);
                                            self.feedback_protocols{pr}.fbSource = fb_source{end};
                                            btn = questdlg('Use this file(s) for all mock feedback sessions?','Mock feedback','Yes','No','Yes');
                                            switch btn
                                                case 'Yes'
                                                    fb_source_set = 1;
                                                case 'No'
                                                    fb_source_set = 0;
                                            end
                                        end
                                    case 'Use real feedback'
                                        self.feedback_protocols{pr}.fb_type = 'Color intensity';
                                        self.feedback_protocols{pr}.protocol_name = 'Feedback_color';
                                        self.feedback_protocols{pr}.show_as = 'Feedback_color';
                                        self.feedback_protocols{pr}.fb_source = 'real';
                                        btn = questdlg('Use real feedback for all mock feedback sessions?','Mock feedback','Yes','No','Yes');
                                        switch btn
                                            case 'Yes'
                                                fb_source{end+1} = 'real';
                                                fb_source_set = 1;
                                            case 'No'
                                                fb_source_set = 0;
                                        end
                                end
                                disp([num2str(pr) ' mock feedback source ' self.feedback_protocols{pr}.fbSource])
                            end
                        end
                    end
                    self.signals = nfs.derived_signals;
                    self.protocol_sequence = nfs.protocol_sequence;
                    self.csp_settings = nfs.csp_settings;
                    self.feedback_manager.window_size = zeros(length(self.feedback_protocols),1);
                end
                self.protocol_indices = zeros(length(self.feedback_protocols)+1,2); %catch actual data length since 'act_protocol_size' can lie
                
                figure(self.fig_feedback);
                set(self.fig_feedback, 'OuterPosition', [0 0 1920 1080]);
                set(self.fig_feedback,'NumberTitle','off','Name','Feedback');
                
                self.feedback_axis_handle = axes;
                self.feedback_axis_handle.Position = [ 0 0 1 1];
                self.feedback_axis_handle.Tag = 'feedback axis handle';
                
                
                self.fbplot_handle = bar(self.feedback_axis_handle,[0 0 0],'FaceColor',self.bar_color,'Visible','off');
                
                self.fb_stub = uicontrol('Parent', self.fig_feedback, 'String', 'Baseline acquisition', 'Style', 'text', 'ForegroundColor',[0 0 0],'Units', 'normalized','Position', [0.100 0.3500 0.8 0.6], 'FontSize', 75, 'BackgroundColor',[1 1 1], 'FontName', 'Courier New', 'Visible', 'off', 'HorizontalAlignment','Center' );
                self.continue_field = uicontrol('Parent', self.fig_feedback, 'String', 'Press here to continue', 'Style', 'text', 'ForegroundColor',[0 1 0],'Units', 'normalized','Position', [0.100 0.100 0.2 0.2], 'FontSize', 75, 'BackgroundColor',[1 1 1], 'FontName', 'Courier New', 'Visible', 'off', 'HorizontalAlignment','Center','Tag','continue field' );
                if self.show_fb_rect
                    self.common_feedback_rectangle = rectangle('Parent',self.feedback_axis_handle,'FaceColor',[0.63 0.86 0.89],'Position',[0.9 0.5 0.07 0],'Tag','fb_count_rectangle');
                end
                if self.show_fb_count
                    self.fb_count = text('Parent',self.feedback_axis_handle,'String',num2str(self.common_feedback_count),'LineStyle','none',...
                        'FontSize',70,'HorizontalAlignment','left','Position',[0.85 0.05],'Tag','fb_count','Visible','off',...
                        'BackgroundColor','None','Units','normalized');
                end
                set(self.feedback_axis_handle,'Visible','off');
                self.feedback_axis_handle.XLim = [0.5 1];
                self.feedback_axis_handle.YLim = [0.5 1];
                self.feedback_axis_handle.XLimMode = 'manual';
                self.feedback_axis_handle.YLimMode = 'manual';
                self.Connect(predicate,value);
            end
        end
        % строит графики (плохо строит)
        function PlotEEGData(self,timer_obj, event) %#ok<INUSD>
            tic
            if ~self.connected
                log_str = {'Log'};
                for pr = 1:length(self.feedback_protocols)
                    log_str{end+1} = strcat('\color{gray}',self.feedback_protocols{pr}.show_as);
                end
                self.raw_and_ds_figure = figure('Tag','raw_and_ds_figure','Name','Neurofeedback','NumberTitle','off','Menubar','none'); %add Tag
                set(self.raw_and_ds_figure,'ResizeFcn',@self.FitFigure,'CloseRequestFcn',@self.DoNothing,'KeyPressFcn',@self.HandleKBDInput);
                self.connect_button =  uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton','Position', [10 10 150 20], ...
                    'String', 'Start recording','Tag','connect_button');
                if self.from_file
                    self.connect_button.Enable = 'off';
                end
                self.disconnect_button = uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton','Position', [420 10 130 20], ...
                    'String', 'Disconnect', 'Callback', @self.Disconnect,'Tag','disconnect_button');
                %self.log_text = uicontrol('Parent', self.raw_and_ds_figure  ,'Style', 'Text','String', log_str, 'Position', [0 300 50 100],'Tag','log_text');
                
                self.status_text = uicontrol('Parent', self.raw_and_ds_figure,'Style', 'text', 'String', 'Status: ', 'Position', [0 210 200 20],'HorizontalAlignment','left','Tag','status_text');
                self.curr_protocol_text = uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'text','String', 'Current protocol: ', 'Position', [0 40  190 100],'Tag','curr_protocol_text');
                
                %self.edit_protocols_button = uicontrol('Parent',self.raw_and_ds_figure,'Style','pushbutton','Callback',@self.EditProtocols,'Tag','edit_protocols_button','String','Edit protocols');
                select_bad_channels_button = uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton', ...
                    'String', 'Select bad channels', 'Callback', @self.SelectBadChannels,'Tag','select_bad_channels_button');
                %                 bad_channels_text = uicontrol('Parent', self.raw_and_ds_figure,'Style', 'text', 'String', '',...
                %                     'HorizontalAlignment','left','Tag','bad_channels_text');
                self.add_ds_button = uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton','String','Add Composite Signals',...
                    'Callback',@self.CreateCompositeDS,'Tag','add_ds_button');
                self.bluetooth_connect_button = uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton','String','Connect to Bluetooth',...
                    'Callback',@self.ConnectToBluetooth,'Tag','connect_to_bt_button');
                self.two_bars_set_button = uicontrol('Parent',self.raw_and_ds_figure,'style','pushbutton','String','ShowTwoBars',...
                    'Callback',@self.SetTwoBars,'Tag','two_bars_set_button');
                self.raw_subplot = subplot(2,1,1);
                set(self.raw_subplot,'YLim', [0, self.raw_shift*(length(self.used_ch)+1)]);
                self.raw_scale_slider = uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'slider', 'String','Raw scale', 'Value', 0, 'Position', [520 300 10 100], 'Max', 24, 'Min',-24,'SliderStep',[1 1],'Callback',@self.SetYScale,'Tag','raw_slider');
                self.raw_data_indices = 1:length(self.used_ch);
                r_temp = zeros(length(self.raw_data_indices),fix(self.plot_size));
                self.raw_plot = plot(r_temp', 'Parent', self.raw_subplot);
                self.raw_line = uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'Text','String', '', 'Position', [480 320 100 25],'Tag', 'raw_line');
                if ~self.raw_ylabels_fixed
                    self.r_ytick_labels = {' '};
                    for i = 1:length(self.used_ch)
                        self.r_ytick_labels{end+1} = self.used_ch{i};
                    end
                    self.r_ytick_labels{end+1} = ' ';
                    for i = 1:length(self.used_ch)
                        set(self.raw_plot(i),'DisplayName', self.used_ch{i});
                    end
                    self.FitFigure;
                    self.SetYScale;
                    self.raw_ylabels_fixed = 1;
                end
                
                
                
                self.ds_subplot = subplot(2,1,2);
                set(self.ds_subplot,'YLim', [0 self.raw_shift*length(self.derived_signals)]);
                
                self.log_text_axes = axes('Parent',self.raw_and_ds_figure,'Tag','log_text_axes','Units','pixels');
                self.log_text_axes.Visible = 'off';
                self.log_text = text('Parent',self.log_text_axes,'String',log_str, 'Tag','log_text');
                self.log_text.FontSize = 8;
                self.log_text.HorizontalAlignment = 'left';
                self.log_text.VerticalAlignment = 'bottom';
                
                self.FitFigure;
                self.connected = 1;
                
            elseif self.connected
                set(self.raw_subplot,'YLim', [0, self.raw_shift*(length(self.raw_data_indices)+1)]);
                set(self.ds_subplot,'YLim', [0 self.raw_shift*(length(self.derived_signals))]);
                r_sp = get(self.raw_subplot);
                ds_sp = get(self.ds_subplot);
                
                try
                    
                    %plot filtered data
                    if length(self.derived_signals) > 1
                        if ~self.ds_ylabels_fixed && length(self.derived_signals)>1
                            
                            ds_temp = zeros(length(self.derived_signals)-1,fix(self.plot_size));
                            self.ds_plot = plot(ds_temp', 'Parent', self.ds_subplot);
                            self.ds_line = uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'Text','String', '', 'Position', [480 120 100 25],'Tag','ds_line');
                            self.ds_scale_slider= uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'slider', 'String','DS scale', 'Value', 0, 'Position', [520 100 10 100], 'Max', 24, 'Min',-24,'SliderStep',[1 1],'Callback',@self.SetYScale,'Tag','ds_slider');
                            
                            self.ds_ytick_labels = {' '};
                            for i = 2:length(self.derived_signals)
                                self.ds_ytick_labels{end+1} = self.derived_signals{i}.signal_name;
                            end
                            self.ds_ytick_labels{end+1} = ' ';
                            for i = 2:length(self.derived_signals)
                                set(self.ds_plot(i-1),'DisplayName', self.derived_signals{i}.signal_name);
                            end
                            self.ds_ylabels_fixed = 1;
                            self.SetYScale;
                        end
                        %set dropmenu with a choice of derived signals
                        if ~max(size(findobj('Tag','sn_to_fb_dropmenu'))) || ~self.ds_dropmenu_set
                            self.sn_to_fb_string = '';
                            for i = 2:length(self.derived_signals)
                                if i == 2
                                    self.sn_to_fb_string = self.derived_signals{i}.signal_name;
                                else
                                    self.sn_to_fb_string = strcat(self.sn_to_fb_string,'|',self.derived_signals{i}.signal_name);
                                end
                            end
                            if ~max(size(findobj('Tag','sn_to_fb_dropmenu')))
                                self.sn_to_fb_dropmenu = uicontrol('Parent', self.raw_and_ds_figure, 'Style', 'popupmenu', 'String', self.sn_to_fb_string, 'Position',[300 10 100 20], 'Callback', @self.SelectSignalToFeedback,'Tag','sn_to_fb_dropmenu');
                            else
                                set(self.sn_to_fb_dropmenu,'String',self.sn_to_fb_string);
                            end
                            self.FitFigure;
                            self.ds_dropmenu_set = 1;
                        end
                        
                        %plot the ds data
                        ds_first_to_show = self.derived_signals{self.signal_to_feedback}.ring_buff.lst-self.plot_size;
                        ds_last_to_show = self.derived_signals{self.signal_to_feedback}.ring_buff.lst;
                        if ds_first_to_show < ds_last_to_show
                            for i = 2:length(self.derived_signals)
                                if self.derived_signals{i}.ring_buff.lst - self.derived_signals{i}.ring_buff.fst > ds_last_to_show - ds_first_to_show
                                    pulled = self.derived_signals{i}.ring_buff.raw(ds_first_to_show+1:ds_last_to_show,:);
                                    
                                else
                                    pulled = self.derived_signals{i}.ring_buff.raw(self.derived_signals{i}.ring_buff.fst:self.derived_signals{i}.ring_buff.lst);
                                    pulled = vertcat(zeros(self.plot_size-length(pulled),1), pulled);
                                end
                                pulled = pulled';
                                set(self.ds_plot(i-1), 'YData',(pulled(1,:)-mean(pulled(1,:),2))*self.ds_ydata_scale+self.ds_shift*(i-1));
                                
                            end
                        end
                    end
                    
                    %plot raw data
                    raw_first_to_show = self.derived_signals{1}.ring_buff.lst-self.plot_size;
                    raw_last_to_show = self.derived_signals{1}.ring_buff.lst;
                    if raw_last_to_show > raw_first_to_show
                        if self.derived_signals{1}.ring_buff.lst  - self.derived_signals{1}.ring_buff.fst > raw_last_to_show - raw_first_to_show
                            raw_data = self.derived_signals{1}.ring_buff.raw(self.derived_signals{1}.ring_buff.lst-self.plot_size+1:self.derived_signals{1}.ring_buff.lst,:);
                            
                        else
                            raw_data = self.derived_signals{1}.ring_buff.raw(self.derived_signals{1}.ring_buff.fst:self.derived_signals{1}.ring_buff.lst,:);
                            raw_data = vertcat(zeros(self.plot_size - length(raw_data),length(self.used_ch)),raw_data);
                        end
                        raw_data = raw_data';
                        raw_data = raw_data(self.raw_data_indices,:);
                        for i = 1:size(raw_data,1)
                            set(self.raw_plot(i),'YData', (raw_data(i:i,:)- mean(raw_data(i:i,:),2))*self.raw_ydata_scale+self.raw_shift*i);
                        end
                        %self.vals = raw_data;
                    end
                    if ~self.raw_yscale_fixed
                        self.SetRawYTicks;
                        self.raw_yscale_fixed = 1;
                    end
                    
                    %set x limits of the plots
                    xlim(self.ds_subplot, [0 self.plot_size]);
                    xlim(self.raw_subplot, [0 self.plot_size]);
                    set(self.raw_subplot, 'XTick', [0:self.sampling_frequency:self.plot_size]); %#ok<NBRAK>
                    set(self.ds_subplot, 'XTick', [0:self.sampling_frequency:self.plot_size]); %#ok<NBRAK>
                    if self.samples_acquired > self.plot_size
                        set(self.ds_subplot, 'XTickLabel', [self.samples_acquired - ds_sp.XTick(end):ds_sp.XTick(2):self.samples_acquired]); %#ok<NBRAK>
                        set(self.raw_subplot, 'XTickLabel', [self.samples_acquired - r_sp.XTick(end):r_sp.XTick(2):self.samples_acquired]); %#ok<NBRAK>
                    end
                catch
                    'Error while plotting, function PlotEEGData' %#ok<NOPRT>
                end
            end
            %set recording status
            try
                if(self.current_protocol> 0 && self.current_protocol<=length(self.feedback_protocols)) %non-zero protocol
                    if ~self.double_blind
                        if strcmp(self.displayed_feedback,'mock')
                            feedback_message = strcat('Real feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)), '. Mock feedback vector ', num2str(self.mock_feedback_value));
                        else
                            feedback_message = strcat('Feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)));
                        end
                    else
                        if strcmp(self.displayed_feedback,'mock')
                            feedback_message = strcat('Feedback vector ', num2str(self.mock_feedback_value));
                        else
                            feedback_message = strcat('Feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)));
                        end
                    end
                    if verLessThan('matlab','8.4.0')
                        set(self.curr_protocol_text, 'String', [strcat('Current protocol: ',self.feedback_protocols{self.current_protocol}.show_as),...
                            strcat('Samples acquired', num2str(self.feedback_protocols{self.current_protocol}.actual_protocol_size),'/', num2str(self.feedback_protocols{self.current_protocol}.protocol_size)),...
                            strcat(' avg ', num2str(self.feedback_manager.average(self.signal_to_feedback-1))),...
                            strcat(' std ',num2str(self.feedback_manager.standard_deviation(self.signal_to_feedback-1))),...
                            feedback_message,...
                            strcat('Receiving samples every ', num2str(self.data_receive_rate), ' s'),...
                            strcat('Updating plots every ', num2str(self.plot_refresh_rate), ' s')
                            ]);
                    else
                        if strcmpi(self.feedback_protocols{self.current_protocol}.fb_type,'mock')
                            self.curr_protocol_text.String = [strcat('Current protocol: ',self.feedback_protocols{self.current_protocol}.show_as),...
                                strcat('Samples acquired', num2str(self.feedback_protocols{self.current_protocol}.actual_protocol_size),'/', num2str(self.feedback_protocols{self.current_protocol}.protocol_size)),...
                                strcat(' avg ', num2str(self.feedback_manager.average(self.signal_to_feedback-1))),...
                                strcat(' std ',num2str(self.feedback_manager.standard_deviation(self.signal_to_feedback-1))),...
                                feedback_message,...
                                strcat('Receiving samples every ', num2str(self.data_receive_rate), ' s'),...
                                strcat('Updating plots every ', num2str(self.plot_refresh_rate), ' s')
                                ];
                        else
                            self.curr_protocol_text.String = [strcat('Current protocol: ',self.feedback_protocols{self.current_protocol}.show_as),...
                                strcat('Samples acquired', num2str(self.feedback_protocols{self.current_protocol}.actual_protocol_size),'/', num2str(self.feedback_protocols{self.current_protocol}.protocol_size)),...
                                strcat(' avg ', num2str(self.feedback_manager.average(self.signal_to_feedback-1))),...
                                strcat(' std ',num2str(self.feedback_manager.standard_deviation(self.signal_to_feedback-1))),...
                                feedback_message,...
                                strcat('Receiving samples every ', num2str(self.data_receive_rate), ' s'),...
                                strcat('Updating plots every ', num2str(self.plot_refresh_rate), ' s')
                                ];
                        end
                    end
                else %zero protocol
                    if ~self.double_blind
                        if strcmp(self.displayed_feedback,'mock')
                            feedback_message = strcat('Real feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)), '. Mock feedback vector ', num2str(self.mock_feedback_value));
                        else
                            feedback_message = strcat('Feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)));
                        end
                    else
                        if strcmp(self.displayed_feedback,'mock')
                            feedback_message = strcat('Feedback vector ', num2str(self.mock_feedback_value));
                        else
                            feedback_message = strcat('Feedback vector ', num2str(self.feedback_manager.feedback_vector(self.signal_to_feedback-1)));
                        end
                    end
                    if verLessThan('matlab','8.4.0')
                        set(self.curr_protocol_text, 'String', ['Current protocol: idle, ',...
                            strcat(' avg ', num2str(self.feedback_manager.average(self.signal_to_feedback-1))),...
                            strcat(' std ',num2str(self.feedback_manager.standard_deviation(self.signal_to_feedback-1))),...
                            feedback_message,...
                            strcat('Receiving samples every ', num2str(self.data_receive_rate), ' s'),...
                            strcat('Updating plots every ', num2str(self.plot_refresh_rate), ' s')
                            ]);
                    else
                        self.curr_protocol_text.String = ['Current protocol: idle, ',...
                            strcat(' avg ', num2str(self.feedback_manager.average(self.signal_to_feedback-1))),...
                            strcat(' std ',num2str(self.feedback_manager.standard_deviation(self.signal_to_feedback-1))),...
                            feedback_message,...
                            strcat('Receiving samples every ', num2str(self.data_receive_rate), ' s'),...
                            strcat('Updating plots every ', num2str(self.plot_refresh_rate)), ' s'];
                    end
                end
            catch
                'Error while setting the status string, function PlotEEGData' %#ok<NOPRT>
            end
            
            self.SetRecordingStatus;
            self.plot_timing(end+1) = toc;
        end
        % отображает сигнал обратной связи на экране испытуемого.
        function RefreshFB(self,timer_obj,event) %#ok<INUSD>
            tic
            %feedback
            try
                if length(self.derived_signals) > 1 && ishandle(self.fig_feedback)
                    if ~self.feedback_type
                        try
                            if self.current_protocol> 0 && self.current_protocol<=length(self.feedback_protocols)
                                if strcmp(self.feedback_protocols{self.current_protocol}.protocol_name,'Rest')
                                    set(self.fb_stub,'BackgroundColor',[0.7 0.7 0.7]);
                                    set(self.fig_feedback,'Color',[0.7 0.7 0.7 ]);
                                elseif isempty(self.feedback_protocols{self.current_protocol}.string_to_show) && self.show_fb %feedback
                                    
                                    if strfind(lower(self.fb_type),'bar')
                                        
                                        if ~self.fb_bar_source_set
                                            self.fbplot_handle.YDataSource = '[0 self.feedback_manager.feedback_vector(self.signal_to_feedback-1) 0]';
                                            self.fb_bar_source_set = 1;
                                        end
                                        
                                        if ~isnan(self.feedback_manager.feedback_vector(self.signal_to_feedback-1))
                                            refreshdata(self.fbplot_handle,'caller');
                                        end
                                        
                                    elseif ~isempty(strfind(lower(self.fb_type),'color')) || ~isempty(strfind(lower(self.fb_type),'mock'))
                                        if strcmp(self.displayed_feedback,'real') && strcmp(self.feedback_protocols{self.current_protocol}.fb_type,'Color intensity')
                                            if ~isnan(self.feedback_manager.feedback_vector(self.signal_to_feedback-1))
                                                tic
                                                if self.feedback_manager.feedback_vector(self.signal_to_feedback-1) > self.y_limit(2) %self.fb_sigmas - 1
                                                    
                                                    set(self.fig_feedback,'Color',[1 0 0 ]); %feedback mode
                                                    
                                                    %set(self.fig_feedback,'Color',[1 1 1]); %delay test mode
                                                elseif self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1) < self.y_limit(1) %the lowest feedback displayed
                                                    set(self.fig_feedback,'Color',[1 1 1]); %feedback mode
                                                    %set(self.fig_feedback,'Color',[0 0 0]); %delay test mode
                                                    
                                                else
                                                    set(self.fig_feedback,'Color',[1 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1)) 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1))]);
                                                end
                                                self.fb_timing(end+1) = toc;
                                                
                                            end
                                            %elseif strfind(lower(self.fb_type),'mock')
                                        elseif strcmp(self.displayed_feedback,'mock') ||strcmp(self.feedback_protocols{self.current_protocol}.fb_type,'mock')
                                            if ischar(self.feedback_protocols{self.current_protocol}.fb_source) %fb_source == random
                                                if ~isnan(self.feedback_manager.average(self.signal_to_feedback-1) && ~isnan(self.feedback_manager.standard_deviation(self.signal_to_feedback-1)))
                                                    self.mock_feedback_value = random('Normal',0,1) + random('Normal',0,1);
                                                end
                                            elseif isnumeric(self.feedback_protocols{self.current_protocol}.fb_source)
                                                self.mock_feedback_index = self.mock_feedback_index + 1;
                                                if ~mod(self.mock_feedback_index,length(self.feedback_protocols{self.current_protocol}.fb_source))
                                                    self.mock_feedback_index = 1;
                                                end
                                                self.mock_feedback_value = self.feedback_protocols{self.current_protocol}.fb_source(self.mock_feedback_index);
                                                %self.mock_feedback_index
                                            end
                                            if self.mock_feedback_value > self.y_limit(2)
                                                self.mock_feedback_value = self.y_limit(2);
                                            elseif self.mock_feedback_value < self.y_limit(1)
                                                self.mock_feedback_value = self.y_limit(1);
                                            end
                                            if ~isnumeric(self.mock_feedback_value)
                                                1565 %#ok<NOPRT>
                                                self.mock_feedback_value
                                            else
                                                %disp(mock_feedback)
                                                set(self.fig_feedback,'Color',[1 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.mock_feedback_value) 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.mock_feedback_value)]);
                                            end
                                        end
                                    elseif strfind(lower(self.fb_type),'mixed')
                                        if isempty(self.rects)
                                            for r = 1:1:14
                                                self.rects(r) = rectangle('Parent',self.feedback_axis_handle,'Position',[ 0 (r-1)/2 2 0.45],'Curvature', [0.1]); %#ok<NBRAK>
                                            end
                                        end
                                        %determine color and quantity of colored rectangles
                                        quantity = floor((self.feedback_manager.feedback_vector(self.signal_to_feedback-1)+1)/0.5);
                                        color = mod((self.feedback_manager.feedback_vector(self.signal_to_feedback-1)+1),0.5);
                                        for r = 1:length(self.rects)
                                            if r == quantity + 1
                                                set(self.rects(r),'FaceColor',[1 1-color 1-color]);
                                                set(self.rects(r),'EdgeColor',[0 0 0]);
                                            elseif r <= quantity
                                                set(self.rects(r),'FaceColor',[1 0 0]);
                                                set(self.rects(r),'EdgeColor',[0 0 0]);
                                            else
                                                set(self.rects(r),'FaceColor',[1 1 1]);
                                                set(self.rects(r),'EdgeColor',[1 1 1]);
                                            end
                                        end
                                    end
                                end
                            elseif self.fb_statistics_set && self.show_fb %zero protocol after baseline recorded
                                if strfind(lower(self.fb_type),'bar')
                                    if ~isnan(self.feedback_manager.feedback_vector(self.signal_to_feedback-1))
                                        set(self.fbplot_handle,'YData',[0 self.feedback_manager.feedback_vector(self.signal_to_feedback-1) 0]);
                                    end
                                elseif strfind(lower(self.fb_type),'color')
                                    if ~isnan(self.feedback_manager.feedback_vector(self.signal_to_feedback-1))
                                        %tic
                                        try
                                            if self.feedback_manager.feedback_vector(self.signal_to_feedback-1) > self.y_limit(2)%1 - 1/self.fb_sigmas
                                                set(self.fig_feedback,'Color',[1 0 0 ]); %feedback mode
                                                %set(self.fig_feedback,'Color',[1 1 1]); %delay test mode
                                            elseif self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1) < self.y_limit(1)
                                                set(self.fig_feedback,'Color',[1 1 1]); %feedback mode
                                                %set(self.fig_feedback,'Color',[0 0 0]); %delay test mode
                                            else
                                                set(self.fig_feedback,'Color',[1 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1)) 1-(1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1))]);
                                            end
                                            
                                        catch
                                            1289 %#ok<NOPRT>
                                        end
                                        %self.fb_timing(end+1) = toc;
                                    end
                                elseif strfind(lower(self.fb_type),'mixed')
                                    if isempty(self.rects)
                                        for r = 1:1:14
                                            self.rects(r) = rectangle('Parent',self.feedback_axis_handle,'Position',[ 0 (r-1)/2 2 0.45],'Curvature', [0.1]); %#ok<NBRAK>
                                        end
                                    end
                                    %determine color and quantity of colored rectangles
                                    quantity = floor((self.feedback_manager.feedback_vector(self.signal_to_feedback-1)+1)/0.5);
                                    color = mod((self.feedback_manager.feedback_vector(self.signal_to_feedback-1)+1),0.5);
                                    for r = 1:length(self.rects)
                                        if r == quantity + 1
                                            set(self.rects(r),'FaceColor',[1 1-color 1-color]);
                                            set(self.rects(r),'EdgeColor',[0 0 0]);
                                        elseif r <= quantity
                                            set(self.rects(r),'FaceColor',[1 0 0]);
                                            set(self.rects(r),'EdgeColor',[0 0 0]);
                                        else
                                            set(self.rects(r),'FaceColor',[1 1 1]);
                                            set(self.rects(r),'EdgeColor',[1 1 1]);
                                        end
                                    end
                                    
                                end
                                
                            end
                            
                        catch
                            self.feedback_protocols{self.current_protocol}.protocol_name
                            'Error while setting feedback' %#ok<NOPRT>
                            1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1) %#ok<NOPRT>
                        end
                    elseif self.feedback_type == 1
                        
                        if self.show_two_bars
                            self.SetTwoBars;
                            
                        end
                        
                        
                    end
                elseif self.current_protocol
                    try
                        %if ssd or csp or baseline: show string
                        if ~cellfun('isempty',strfind({lower(self.feedback_protocols{self.current_protocol}.protocol_name)},'ssd')) ||~cellfun('isempty',strfind({lower(self.feedback_protocols{self.current_protocol}.protocol_name)},'csp'))||~cellfun('isempty',strfind({lower(self.feedback_protocols{self.current_protocol}.protocol_name)},'baseline'))
                            
                            set(self.fb_stub,'String',self.feedback_protocols{self.current_protocol}.string_to_show);
                            set(self.fb_stub,'Visible','on');
                            
                            set(self.feedback_axis_handle,'Visible','off');
                            set(self.fbplot_handle,'Visible','off');
                            set(self.fb_stub,'BackgroundColor',[0.7 0.7 0.7]);
                            set(self.fig_feedback,'Color',[0.7 0.7 0.7 ]);
                            
                        end
                    catch
                        1775 %#ok<NOPRT>
                    end
                elseif ishandle(self.fig_feedback)%zero protocol before baseline recorded
                    try
                        set(self.feedback_axis_handle,'Visible','off');
                        set(self.fbplot_handle,'Visible','off');
                        set(self.fb_stub,'Visible','off'); %string
                        set(self.fb_stub,'BackgroundColor',[0.7 0.7 0.7]);
                        set(self.fig_feedback,'Color',[0.7 0.7 0.7 ]);
                    catch
                        1783 %#ok<NOPRT>
                    end
                    
                end
                %bluetooth
                %                 try
                %                     self.TransmitToBluetooth();
                %                 catch
                %                     1786 %#ok<NOPRT>
                %                 end
            catch
                1831 %#ok<NOPRT>
            end
            
            try
                self.FbToLSL;
            catch
                1466 %#ok<NOPRT>
            end
            %self.fb_timing(end+1) = toc;
            try
                if self.show_two_bars
                    self.SetTwoBars;
                end
            catch
                1760;
            end
        end
        % заполняет данные для столбцов
        function SetTwoBars(self,obj,event) %#ok<INUSD>
            tic
            try %#ok<TRYNC>
                if ~ishandle(self.two_bars_figure)
                    % if strcmp(self.two_bars_figure.Visible,'off') || ~ishandle(self.two_bars_figure)
                    [self.two_bars_signals(1), self.two_bars_signals(2)] = self.SelectSignals;
                    self.two_bars_figure = figure('Tag','two_bars_figure','NumberTitle','off','Name','Two bars');
                    
                    self.left_bar = subplot(1,2,1);
                    self.right_bar = subplot(1,2,2);
                    
                    
                    self.bar1 = bar(self.left_bar,0);
                    self.bar2 = bar(self.right_bar,0);
                    self.bar1_data = [];
                    self.bar2_data = [];
                    self.two_bars_protocol = self.current_protocol;
                    self.left_bar.YLim = [-3 3];
                    self.right_bar.YLim = [-3 3];
                    self.left_bar.YLimMode = 'manual';
                    self.right_bar.YLimMode = 'manual';
                    % text('Parent',self.left_bar,'String','curr pr mean','Position', [ 0 -2]);
                    % text('Parent',self.right_bar,'String','curr pr mean','Tag','Position', [ 0 -2]);
                    
                    self.show_two_bars = 1;
                    
                end
            end
            
            if self.two_bars_protocol ~= self.current_protocol
                if self.two_bars_protocol
                    self.feedback_protocols{self.two_bars_protocol}.protocol_name
                end
                self.two_bars_protocol = self.current_protocol;
                mean(self.bar1_data)
                mean(self.bar2_data)
                self.bar1_data = [];
                self.bar2_data = [];
            end
            
            l = self.two_bars_signals(1);
            r = self.two_bars_signals(2);
            if l > 1
                ch1 = self.feedback_manager.feedback_vector(l-1);
            else
                ch1 = 0;
            end
            
            if r > 1
                ch2 = self.feedback_manager.feedback_vector(r-1);
            else
                ch2 = 0;
            end
            if ~(ch1&&ch2)
                close(self.two_bars_figure);
                self.show_two_bars = 0;
            else
                self.bar1.YData = ch1;
                self.bar2.YData = ch2;
            end
            %tic
            self.bar1_data = [self.bar1_data ch1];
            self.bar2_data = [self.bar2_data ch2];
            %self.left_bar.Title.String = num2str(mean(self.bar1_data));
            %self.right_bar.Title.String = num2str(mean(self.bar2_data));
            %a = toc
            l_t = findobj('Tag','left_text');
            r_t = findobj('Tag','right_text');
            delete(l_t);
            delete(r_t);
            text('Parent',self.left_bar,'String',num2str(mean(self.bar1_data)),'Tag','left_text','Position', [ 1 -2]);
            text('Parent',self.right_bar,'String',num2str(mean(self.bar2_data)),'Tag','right_text','Position', [ 1 -2]);
            
        end
        % включает запись
        function StartRecording(self,obj,event) %#ok<INUSD>
            if self.from_file && ~self.run_protocols
                self.current_protocol = self.next_protocol;
                self.next_protocol = self.next_protocol + 1;
            else
                self.current_protocol = self.next_protocol;
                self.next_protocol = self.next_protocol + 1;
            end
            if self.current_protocol > 0 && self.current_protocol <= length(self.feedback_protocols)
                self.log_text.String{self.current_protocol+1} = strcat('\color{red}',self.feedback_protocols{self.current_protocol}.show_as);
                if self.current_protocol <= length(self.feedback_manager.window_size)
                    self.current_window_size = self.feedback_manager.window_size(self.current_protocol);
                    self.default_window_size =  self.current_window_size;
                else
                    self.current_window_size = self.default_window_size;
                end
            elseif self.default_window_size == 0 %zero protocol at the beginning
                self.current_window_size = self.feedback_manager.window_size(1);
            else  %zero protocol after some data was recorded
                self.current_window_size = self.default_window_size;
            end
            self.paused = 0;
            self.recording = 1;
            self.InitTimer();
            set(self.connect_button, 'String', 'Stop recording');
            set(self.connect_button, 'Callback', @self.StopRecording);
            self.SetFBWindow;
        end
        % останавливает запись
        function StopRecording(self, obj,event) %#ok<INUSD>
            self.recording = 0;
            if self.current_protocol >= length(self.feedback_protocols)
                if self.current_protocol == length(self.feedback_protocols) && self.feedback_protocols{self.current_protocol}.stop_after
                    self.current_protocol = 0;
                    self.tstop = toc(self.tstart);
                elseif self.current_protocol > length(self.feedback_protocols)
                    self.current_protocol = 0;
                end
                self.finished = 1;
                set(self.connect_button,'enable', 'off');
                temp_log_text = get(self.log_text,'String');
                temp_log_text{end+1} = 'Finished';
                set(self.log_text,'String',temp_log_text);
                set(self.disconnect_button,'String','Disconnect and write');
                set(self.connect_button, 'String', 'Recording finished');
                set(self.connect_button,'Callback','');
                %self.PlotFB;
                self.PlotErrorBar;
            end
            if  ~self.finished
                if self.feedback_protocols{self.current_protocol}.actual_protocol_size*1.1 < self.feedback_protocols{self.current_protocol}.protocol_size
                    self.next_protocol = self.current_protocol;
                    set(self.connect_button, 'String', 'Continue recording');
                    self.paused = 1;
                else
                    self.next_protocol = self.current_protocol + 1;
                    set(self.connect_button, 'String', 'Start recording');
                end
                self.current_protocol = 0;
                
                set(self.connect_button, 'Callback', @self.StartRecording);
            end
        end
        % отключение от блютус канала? возможно не используется
        function Disconnect(self, obj,event) %#ok<INUSD>
            if self.bt_connected
                self.bt_connected = 0;
                fclose(self.bluetooth_connection);
                self.bluetooth_connect_button.String = 'Connect to Bluetooth';
                self.bluetooth_connect_button.Enable = 'off';
            end
            stop(self.timer_new_data);
            stop(self.timer_disp);
            stop(self.timer_fb);
            set(self.fb_stub,'Visible','off');
            set(self.status_text, 'String', 'Status: disconnected');
            set(self.connect_button, 'String', 'Resume recording');
            set(self.connect_button, 'Callback',{@self.Connect});
            self.inlet.close_stream();
            self.subject_record.time_stop = datestr(now,13);
            if self.finished
                self.WriteToFile;
                save('eeg.mat','self');
            end
        end
        % строит графики столцов ошибок
        function PlotErrorBar(self)
            
            %protocols:
            protocols = (self.ssd+1):length(self.feedback_protocols);
            
            %signals
            
            averages = zeros(length(protocols),length(self.derived_signals)-1);
            deviations =  zeros(length(protocols),length(self.derived_signals)-1);
            names = cell(length(protocols),1);
            plot_size = length(protocols);
            head_str = 'Protocol';
            for pr = protocols
                if any([strfind(lower(self.feedback_protocols{pr}.protocol_name),'ssd'),strfind(lower(self.feedback_protocols{pr}.protocol_name),'csp')])
                    plot_size = length(self.feedback_protocols)-1;
                else
                    names{pr-self.ssd} = self.feedback_protocols{pr}.show_as;
                    for ds = 2:length(self.derived_signals)
                        ds_idx_start = self.protocol_indices(pr,(ds-1)*2+1);
                        ds_idx_stop = self.protocol_indices(pr,(ds-1)*2+2);
                        dat = self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst+ds_idx_start: self.derived_signals{ds}.collect_buff.fst+ds_idx_stop-1);
                        if ~isempty(self.derived_signals{ds}.statvalues)
                            m = mean(abs(self.derived_signals{ds}.statvalues));
                            d = std(abs(self.derived_signals{ds}.statvalues));
                        elseif ~isempty(self.derived_signals{ds}.file_av)
                            m = self.derived_signals{ds}.file_av;
                            d = self.derived_signals{ds}.file_std;
                        else
                            m = self.feedback_manager.average(ds-1);
                            d = self.feedback_manager.standard_deviation(ds-1);
                        end
                        fb = self.Recalculate(abs(dat),self.feedback_protocols{pr}.window_size, m, d);
                        averages(pr-self.ssd,ds-1) = mean(fb);
                        deviations(pr-self.ssd,ds-1) = std(fb);
                    end
                end
            end
            for ds = 2:length(self.derived_signals)
                head_str = [head_str ', ' self.derived_signals{ds}.signal_name ' av, ' self.derived_signals{ds}.signal_name ' std'];
            end
            %write to file
            curr_date = datestr(date,29);
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
            end
            filename = strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\','stats.txt');
            f = fopen(filename,'w');
            fprintf(f, head_str);
            fprintf(f,'\n');
            for i = 1:length(names)
                s = names{i};
                for ds = 2:length(self.derived_signals)
                    s = [s ' ' num2str(averages(i,ds-1)) ' ' num2str(deviations(i,ds-1))];
                end
                s = [s '\n'];
                fprintf(f,s);
            end
            fclose(f);
            disp('Stats have been written successfully')
            %show plot
            names = [names' ' '];
            legend_str = {};
            
            f = figure;
            for ds = 1:length(self.derived_signals)-1
                e = errorbar(averages(:,ds), deviations(:,ds));
                hold on;
                legend_str{end+1} = self.derived_signals{ds+1}.signal_name;
            end
            set(gca,'XTick',1:plot_size);
            set(gca,'XTickLabel',names);
            xlabel('Protocols');
            ylabel('Normalized values of calculated feedback (Mean +/- std)');
            legend(legend_str);
            
        end
        % записывает в файл так как надо и в тот что надо
        function WriteToFile(self)
            curr_date = datestr(date,29);
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
            end
            cd(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
            string = '';
            for c = 1:length(self.used_ch)
                if c == 1
                    string = self.used_ch{c,1};
                else
                    string = strcat(string, ',', self.used_ch{c,1});
                end
            end
            
            
            for pr = 1:length(self.feedback_protocols)
                raw_idx_start = self.protocol_indices(pr,1);
                raw_idx_stop = self.protocol_indices(pr,2);
                if pr == self.ssd + 1
                    fb_idx = raw_idx_start;
                end
                
                
                if pr <= self.ssd
                    raw_data_matrix = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+raw_idx_start:self.derived_signals{1}.collect_buff.fst+raw_idx_stop-1,:);
                    whole_data = raw_data_matrix;
                    if strfind(lower(self.feedback_protocols{pr}.protocol_name),'ssd')
                        inf_file = fopen('ssd_exp_info.hdr','w');
                    elseif strfind(lower(self.feedback_protocols{pr}.protocol_name),'csp')
                        inf_file = fopen('csp_exp_info.hdr','w');
                    end
                    if exist('inf_file','var')
                        try %#ok<TRYNC>
                            fprintf(inf_file,string); %basically writes channels' names only
                            fclose(inf_file);
                        end
                    end
                    
                    
                    
                else
                    fb_idx_start = raw_idx_start - fb_idx;
                    fb_idx_stop = raw_idx_stop - fb_idx;
                    raw_data_matrix = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+raw_idx_start:self.derived_signals{1}.collect_buff.fst+raw_idx_stop-1,:);
                    if ~isempty(self.feedback_manager.feedback_records)
                        fb_matrix = self.feedback_manager.feedback_records.raw(self.feedback_manager.feedback_records.fst+fb_idx_start:self.feedback_manager.feedback_records.fst+fb_idx_stop-1, :);
                    end
                    if exist('fb_matrix','var')
                        data_matrix = zeros(size(fb_matrix,1), length(self.derived_signals)-1);
                        for ds = 2:length(self.derived_signals)
                            ds_idx_start = self.protocol_indices(pr,(ds-1)*2+1);
                            ds_idx_stop = self.protocol_indices(pr,(ds-1)*2+2);
                            if ~(ds_idx_stop - ds_idx_start) %#ok<BDLOG>
                                data_matrix(:,ds-1) = 0;
                            elseif size(self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst+ds_idx_start:self.derived_signals{ds}.collect_buff.fst+ds_idx_stop-1, :),1) < size(data_matrix,1)
                                d = size(data_matrix,1) - size(self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst+ds_idx_start:self.derived_signals{ds}.collect_buff.fst+ds_idx_stop-1, :),1);
                                data_matrix(d+1:end,ds-1) = self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst+ds_idx_start:self.derived_signals{ds}.collect_buff.fst+ds_idx_stop-1, :);
                            else
                                data_matrix(:,ds-1) = self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst+ds_idx_start:self.derived_signals{ds}.collect_buff.fst+ds_idx_stop-1, :);
                            end
                        end
                    end
                    
                    if ~isempty(self.feedback_manager.feedback_records)
                        whole_data = [raw_data_matrix data_matrix fb_matrix];
                    elseif exist('data_matrix','var')
                        whole_data = [raw_data_matrix data_matrix];
                    else
                        whole_data = raw_data_matrix;
                    end
                    
                end
                
                %write data
                if ~isempty(whole_data)
                    filename = [num2str(pr) ' ' self.feedback_protocols{pr}.protocol_name ' '...
                        self.feedback_protocols{pr}.show_as ' '...
                        num2str(self.feedback_protocols{pr}.actual_protocol_size/self.sampling_frequency) '.bin'];
                    
                    f = fopen(filename,'w');
                    fwrite(f,size(whole_data),'int');
                    fwrite(f,whole_data, 'double');
                    fclose(f);
                end
                
                
            end
            %write header
            for j = 2:length(self.derived_signals)
                string = strcat(string,',',self.derived_signals{j}.signal_name);
            end
            if ~isempty(self.feedback_manager.feedback_records)
                string = strcat(string,',','Feedbacked signal', ',','Fb values',',','Average',',','Stddev',',','Window size',',','Window num');
            end
            inf_file = fopen('exp_info.hdr','w');
            fprintf(inf_file,string);
            fclose(inf_file);
            
            %if double_blind, record info about mock_feedback
            if self.double_blind
                if strcmp(self.displayed_feedback,'mock')
                    mock_feedback = 1;
                else
                    mock_feedback = 0;
                end
                save(strcat(self.path,'\',self.subject_record.subject_name,'\','fb.bin'),'mock_feedback');
            end
            
            
            %prepare the struct with exp.design and write it
            self.ExpDesignToXML;
            self.recorded = 1;
            %write notes
            self.AddNotes;
            
        end
        % позволяет ввести описание и сохранить в файл
        function AddNotes(self)
            if ~isempty(self.bad_channels)
                notes_string = {['The channels ' strjoin(self.bad_channels) ' were excluded from analysis.']};
            else
                notes_string = {};
            end
            
            %             if self.double_blind
            %                 notes_string{end+1} = 'Double blind: on';
            %                 notes_string{end+1} = ['Displayed feedback: ' self.displayed_feedback];
            %             else
            %                 notes_string{end+1} = 'Double blind: off';
            %             end
            
            self.add_notes_window = figure;
            self.add_notes_field = uicontrol('Parent', self.add_notes_window, 'Style', 'edit', 'Position',...
                [ 10 30 300 200],'String', notes_string,'Max', 2,'HorizontalAlignment','Left'); %there's no such thing as VerticalAlignment in uicontrols
            self.write_notes = uicontrol('Parent', self.add_notes_window, 'Style', 'pushbutton', 'Position',[ 150 10 100 20], 'Callback', 'uiresume', 'String', 'Save notes');
            uiwait;
            notes = '';
            if verLessThan('matlab','8.4.0')
                notes = get(self.add_notes_field, 'String');
            else
                if ishandle(self.add_notes_field)
                    notes = self.add_notes_field.String;
                end
            end
            f = fopen('notes.txt','w');
            if  ~isempty(notes)
                for s = 1:length(notes)
                    fprintf(f,'%s\n',notes{s});
                    
                end
            end
            fclose(f);
            if ishandle(self.add_notes_window)
                close(self.add_notes_window);
            end
            if ishandle(self.raw_and_ds_figure)
                close(self.raw_and_ds_figure);
            end
        end
        % работает ли этот метод? присутствует только часть для старых
        % версий матлаб
        function SetRecordingStatus(self)
            if verLessThan('matlab','8.4.0')
                
                if self.from_file && isempty(self.feedback_protocols)
                    set(self.status_text,'String', 'Playing from file');
                    % zero protocol 
                elseif ( self.current_protocol == 0 || self.current_protocol > length(self.feedback_protocols)) && ~isempty(self.streams)
                    set(self.status_text, 'String','Status: receiving');
                    % when streams were lost
                elseif isempty(self.streams)
                    set(self.status_text,'String','The stream has been lost. Waiting to reconnect...');
                    % all protocols
                else
                    set(self.status_text,'String',strcat('Status: Recording  ', self.feedback_protocols{self.current_protocol}.show_as, ' : ',num2str(round(self.feedback_protocols{self.current_protocol}.actual_protocol_size/self.sampling_frequency)), '/',num2str(self.feedback_protocols{self.current_protocol}.protocol_duration)));
                end
                if self.paused
                    set(self.status_text,'String', ['Protocol ' self.feedback_protocols{self.next_protocol}.show_as ' paused.'...
                        num2str(round(self.feedback_protocols{self.next_protocol}.actual_protocol_size/self.sampling_frequency)) '/'...
                        num2str(self.feedback_protocols{self.next_protocol}.protocol_duration)]);
                end
            else
                
                if self.from_file && isempty(self.feedback_protocols)
                    self.status_text.String = 'Playing from file';
                elseif (self.current_protocol == 0 || self.current_protocol > length(self.feedback_protocols)) && ~isempty(self.streams)
                    self.status_text.String = 'Status: receiving';
                elseif isempty(self.streams)
                    set(self.status_text,'String','The stream has been lost. Waiting to reconnect...');
                else
                    self.status_text.String = strcat('Status: Recording  ', self.feedback_protocols{self.current_protocol}.show_as, ': ',num2str(round(self.feedback_protocols{self.current_protocol}.actual_protocol_size/self.sampling_frequency)), '/',num2str(self.feedback_protocols{self.current_protocol}.protocol_duration));
                end
                if self.paused
                    set(self.status_text,'String',['Protocol ' self.feedback_protocols{self.next_protocol}.show_as ' paused.'...
                        num2str(round(self.feedback_protocols{self.next_protocol}.actual_protocol_size/self.sampling_frequency)) '/'...
                        num2str(self.feedback_protocols{self.next_protocol}.protocol_duration)]);
                end
            end
        end
        function SetYScale(self,obj,event)
            if nargin < 2
                self.SetDSYTicks;
                self.SetRawYTicks;
            else
                if strcmp(obj,'KBD')
                    
                    self.raw_scale_slider.Value = event(1);
                    self.raw_ydata_scale = 2^self.raw_scale_slider.Value;
                    
                    if ishandle(self.ds_scale_slider)
                        self.ds_scale_slider.Value = event(2);
                        self.ds_ydata_scale = 2^self.ds_scale_slider.Value ;
                    end
                    
                    self.SetDSYTicks;
                    self.SetRawYTicks;
                elseif strcmp(get(obj,'String'),'DS scale')
                    self.ds_ydata_scale =  fix(1.7^get(obj,'Value'));
                    self.SetDSYTicks;
                elseif strcmp(get(obj,'String'),'Raw scale')
                    self.raw_ydata_scale = fix(1.7^get(obj,'Value'));
                    self.SetRawYTicks;
                    
                end
            end
            
        end
        % устанавливает путь
        function SetWorkpath(self,~,~)
            p = uigetdir;
            if p
                self.path = uigetdir;
            end
            if verLessThan('matlab','8.4.0')
                set(self.path_text,'String',self.path);
            else
                self.path_text.String = self.path;
            end
        end
        function SetDesignFile(self,~,~)
            [fname, fpath, fspec] = uigetfile('*.*');
            if ~isempty(nonzeros([fname fpath fspec]))
                self.settings_file = strcat(fpath,fname);
                if verLessThan('matlab','8.4.0')
                    set(self.settings_file_text, 'String',self.settings_file);
                else
                    self.settings_file_text.String = self.settings_file;
                end
            end
        end
        % закоментирован вызов в RunInterface
        function SetMontageFile(self,~,~)
            [fname, fpath, fspec] = uigetfile('*.*');
            if ~isempty(nonzeros([fname fpath fspec]))
                self.montage_fname = strcat(fpath,fname);
                if verLessThan('matlab','8.4.0')
                    set(self.montage_fname_text, 'String',fname);
                else
                    self.montage_fname_text.String = self.montage_fname;
                end
            end
        end
        function SelectSignalToFeedback(self,obj,event) %#ok<INUSD>
            if verLessThan('matlab','8.4.0')
                self.signal_to_feedback = get(obj,'Value')+1;
            else
                self.signal_to_feedback = obj.Value+1;
            end
        end
        % заполняет фигуру необходимым в нужных местах
        function FitFigure(self,obj, event) %#ok<INUSD>
            f = findobj('Tag','raw_and_ds_figure');
            fp = get(f,'Position');
            cb = findobj('Tag','connect_button');
            db = findobj('Tag','disconnect_button');
            dss = findobj('Tag','ds_slider');
            rss = findobj('Tag','raw_slider');
            dm = findobj('Tag','sn_to_fb_dropmenu');
            lta = findobj('Tag','log_text_axes');
            st = findobj('Tag','status_text');
            cpt = findobj('Tag','curr_protocol_text');
            rl = findobj('Tag', 'raw_line');
            dsl = findobj('Tag','ds_line');
            sb = findobj('Tag','settings_button');
            sbch = findobj('Tag','select_bad_channels_button');
            epb = findobj('Tag','edit_protocols_button');
            adb = findobj('Tag','add_ds_button');
            btc = findobj('Tag','connect_to_bt_button');
            tbsb = findobj('Tag','two_bars_set_button');
            try %#ok<TRYNC>
                ok = findobj('Tag', 'add_bad_channel_button');
                fin = findobj('Tag','finish adding bad channels button');
                bcht = findobj('Tag','bad_channels_text');
                cht = findobj('Tag','ch_text');
            end
            
            set(db,'Position',[0.85*fp(3), 0.02*fp(4), 0.12*fp(3), 0.04*fp(4)]);
            set(cb,'Position',[0.03*fp(3), 0.02*fp(4), 0.12*fp(3), 0.04*fp(4)]);
            set(dss,'Position',[0.93*fp(3),0.12*fp(4) , 0.02*fp(3), 0.3*fp(4)]);
            set(rss,'Position',[0.93*fp(3),0.60*fp(4) , 0.02*fp(3), 0.3*fp(4)]);
            set(lta,'Position',[0.01*fp(3) 0.6*fp(4) 0.1*fp(3), 0.4*fp(4)]);
            set(st,'Position', [0 0.49*fp(4), 0.3*fp(3), 0.05*fp(4)]);
            set(cpt, 'Position',[0.2*fp(3) 0.49*fp(4), 0.7*fp(3), 0.05*fp(4)]);
            set(dm,'Position', [0.55*fp(3), 0.015*fp(4),0.15*fp(3),0.04*fp(4)]);
            set(rl,'Position', [0.8 * fp(3), 0.62 *fp(4), 0.05*fp(3), 0.02*fp(4)]);
            set(dsl,'Position', [0.8 * fp(3), 0.15 *fp(4), 0.05*fp(3), 0.02*fp(4)]);
            set(epb,'Position', [0.7*fp(3), 0.945*fp(4), 0.2*fp(3), 0.05*fp(4)]);
            set(sb,'Position', [0.1*fp(3), 0.94*fp(4),0.1*fp(3), 0.05*fp(4)]);
            set(ok,'Position', [0.65*fp(3), 0.94*fp(4), 0.1*fp(3),0.05*fp(4)]);
            set(fin,'Position', [0.75*fp(3), 0.94*fp(4), 0.1*fp(3),0.05*fp(4)]);
            set(bcht, 'Position',[fp(3)*0.2,fp(4)*0.7,fp(3)*0.05,fp(4)*0.2]);
            set(cht,'Position', [fp(3)*0.35, fp(4)*0.94, fp(3)*0.3, fp(4)*0.05]);
            set(sbch,'Position',[fp(3)*0.14, fp(4)*0.945, fp(3)*0.2, fp(4)*0.05]);
            set(adb,'Position',[0.4*fp(3), 0.945*fp(4), 0.25*fp(3), 0.05*fp(4)]);
            set(btc,'Position',[0.25*fp(3), 0.02*fp(4), 0.25*fp(3), 0.04*fp(4)]);
            set(tbsb,'Position',[0.7*fp(3), 0.02*fp(4), 0.1*fp(3), 0.04*fp(4)]);
            self.SetRawYTicks;
            self.SetDSYTicks;
            
            
            fc = findobj('Tag','fb_count');
            set(fc,'Position',[0.8, 0.1]);
        end
        function SetRawYTicks(self)
            try %#ok<TRYNC>
                r_sp = get(self.raw_subplot);
                
                if self.raw_shift > r_sp.YLim(2) - r_sp.YLim(1)
                    self.raw_shift = (r_sp.YLim(2) - r_sp.YLim(1))/length(self.used_ch);
                end
                
                r_yticks = [r_sp.YLim(1):(r_sp.YLim(2)-r_sp.YLim(1))/(length(self.raw_data_indices)+1):r_sp.YLim(2)]; %#ok<NBRAK>
                set(self.raw_subplot, 'YTick', r_yticks);
                set(self.raw_subplot, 'YTickLabel', self.r_ytick_labels);
                set(self.raw_line,'String',num2str((r_sp.YLim(2)-r_sp.YLim(1))/(length(self.raw_data_indices)+1)/self.raw_ydata_scale));
            end
            %self.FitFigure;
        end
        function SetDSYTicks(self)
            try %#ok<TRYNC>
                ds_sp = get(self.ds_subplot);
                ds_yticks = [ds_sp.YLim(1):self.ds_shift:ds_sp.YLim(2)]; %#ok<NBRAK>
                set(self.ds_subplot, 'YTick', ds_yticks);
                set(self.ds_subplot, 'YTickLabel', self.ds_ytick_labels);
                set(self.ds_line,'String',num2str((ds_sp.YLim(2)-ds_sp.YLim(1))/(length(self.derived_signals))/self.ds_ydata_scale));
            end
        end
        % позволяет выбрать испытуемого или добавить данные о новом
        % испытуемом
        function SetSubject(self,obj,event) %#ok<INUSD>
            if strcmp(obj.String{obj.Value},'Add a new subject')
                p = get(obj,'Position');
                p(2) = p(2)-2;
                p(4) = p(4)+2;
                subj_text = uicontrol('Parent',self.fig_interface,'Style','edit','String', '','Position',p);
                subj_tip = uicontrol('Parent',self.fig_interface,'Style','text','String', 'Press Enter when finished', 'Position', [p(1) + p(3), p(2), 150, 20]);
                waitfor(subj_text,'String');
                self.subject_record.subject_name = strtrim(subj_text.String); %remove leading and trailing spaces
                set(obj,'String',[{subj_text.String} obj.String']);
                delete(subj_text);
                delete(subj_tip);
                set(obj,'Value', 1);
            else
                self.subject_record.subject_name = obj.String{obj.Value};
            end
        end
        % прописывает путь до папки испытуемого
        function SetSubjectFolder(self,obj,event) %#ok<INUSD>
            subj_directory = uigetdir;
            if subj_directory
                [~, b, ~ ] = fileparts(subj_directory);
                if b
                    self.subject_record.subject_name = b;
                    set(self.subjects_dropmenu,'String',[{b} get(self.subjects_dropmenu,'String')']);
                    set(self.subjects_dropmenu,'Value',1);
                end
            end
        end
        
        % протоколы протоколу протоколы не используеются есть
        % закоментированная строчка в function PlotEEGData
        function EditProtocols(self,obj,event) %#ok<INUSD>
            if min(length(findobj('Tag', 'EditProtocolFigure'))) %if it already exists, bring it to front
                uistack(findobj('Tag', 'EditProtocolFigure'));
            end
            protocol_figure = figure('Tag','EditProtocolFigure');
            delta_y = protocol_figure.Position(4)/(length(self.feedback_protocols)+3);
            max_height = protocol_figure.Position(4);
            existing_prs = cell(length(self.feedback_protocols),1);
            for p = 1:length(self.feedback_protocols)
                bgr = 0.94-[0.1 0.1 0.1] * mod(p-1,2);
                existing_prs{p} = self.feedback_protocols{p}.protocol_name;
                protocol_count{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.01,max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(p),'HorizontalAlignment','left','Tag','Protocol count','BackgroundColor',bgr);
                protocol_name{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.04,max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.25, protocol_figure.Position(4)*0.04],'String', existing_prs{p},'HorizontalAlignment','left','Tag','Protocol name text','BackgroundColor',bgr);
                
                if p < self.next_protocol %already recorded; duration cannot be changed
                    self.protocol_duration_text{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.3, max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(self.feedback_protocols{p}.protocol_duration),'Tag','Protocol duration text','HorizontalAlignment','right');
                else
                    self.protocol_duration_text{p} = uicontrol('Parent',protocol_figure,'Style','edit','Position', [protocol_figure.Position(3)*0.3, max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(self.feedback_protocols{p}.protocol_duration),'HorizontalAlignment','right','Tag', 'Protocol duration text');
                    
                end
                ms{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.35,max_height-protocol_figure.Position(4)*0.05*p,protocol_figure.Position(3)*0.02 , protocol_figure.Position(4)*0.04],'String', 's','HorizontalAlignment','left','BackgroundColor',bgr,'Tag','s text');
            end
            
            
            prs_types = {};
            for pt = 1:length(self.protocol_types)
                prs_types = [prs_types {self.protocol_types{pt}.sProtocolName}];
            end
            pr_dpmenu = {};
            for p = self.next_protocol-1:length(existing_prs)
                if p < 1
                    continue;
                end
                
                pr_dpmenu = [pr_dpmenu {[num2str(p) ' ' protocol_name{p}.String]}];
            end
            if self.next_protocol == 1
                
                ins_pr_dpmenu = [{'0'} pr_dpmenu];
                del_pr_dpmenu = pr_dpmenu;
            else
                ins_pr_dpmenu = pr_dpmenu;
                del_pr_dpmenu = pr_dpmenu(2:end);
            end
            
            
            add_protocol_text = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.4,protocol_figure.Position(4)*0.92,protocol_figure.Position(3)*0.20 , protocol_figure.Position(4)*0.05],'String', 'Add a protocol','HorizontalAlignment','right');
            insert_protocol_text = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.4,protocol_figure.Position(4)*0.85,protocol_figure.Position(3)*0.20 , protocol_figure.Position(4)*0.05],'String', 'Insert after','HorizontalAlignment','right');
            
            add_protocol_dropmenu = uicontrol('Parent',protocol_figure,'Style','popupmenu','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.925,protocol_figure.Position(3)*0.2 , protocol_figure.Position(4)*0.05],'String', prs_types,'Tag','Add protocol dropmenu');
            insert_protocol_dropmenu = uicontrol('Parent',protocol_figure,'Style','popupmenu','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.855,protocol_figure.Position(3)*0.2 , protocol_figure.Position(4)*0.05],'String', ins_pr_dpmenu,'Tag', 'Insert protocol dropmenu');
            add_protocol_pushbutton =uicontrol('Parent',protocol_figure,'Style','pushbutton','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.78, protocol_figure.Position(3)*0.2, protocol_figure.Position(4)*0.06],'String', 'Add','Tag','add_protocol_button','Callback',@self.AddProtocol);
            
            delete_protocol_text = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.4,protocol_figure.Position(4)*0.6,protocol_figure.Position(3)*0.2 , protocol_figure.Position(4)*0.05],'String', 'Delete a protocol','HorizontalAlignment','right');
            delete_protocol_pushbutton = uicontrol('Parent',protocol_figure,'Style','pushbutton','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.53, protocol_figure.Position(3)*0.2, protocol_figure.Position(4)*0.06],'String', 'Delete','Tag','delete_protocol_button','Callback',@self.DeleteProtocol);
            if isempty(del_pr_dpmenu)
                
                set(delete_protocol_pushbutton,'enable','off');
                delete_protocol_dropmenu = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.6,protocol_figure.Position(3)*0.2 , protocol_figure.Position(4)*0.05],'String', 'No protocols to delete','Tag','Delete protocol dropmenu');
            else
                delete_protocol_dropmenu = uicontrol('Parent',protocol_figure,'Style','popupmenu','Position', [protocol_figure.Position(3)*0.62,protocol_figure.Position(4)*0.61,protocol_figure.Position(3)*0.2 , protocol_figure.Position(4)*0.05],'String', del_pr_dpmenu,'Tag','Delete protocol dropmenu');
                set(delete_protocol_pushbutton,'enable','on');
            end
            
            
            okay_button = uicontrol('Parent',protocol_figure,'Style','pushbutton','Position', [protocol_figure.Position(3)*0.75,delta_y/2, protocol_figure.Position(3)*0.09,protocol_figure.Position(4)*0.12],'String', 'Apply','Tag','okay_button','Callback',@self.ChangeProtocols);
            cancel_button = uicontrol('Parent',protocol_figure,'Style','pushbutton','Position', [protocol_figure.Position(3)*0.85,delta_y/2, protocol_figure.Position(3)*0.09, protocol_figure.Position(4)*0.12],'String', 'Cancel','Tag','cancel_button','Callback',@self.DoNothing);
            
        end
        function AddProtocol(self,obj,event) %#ok<INUSD>
            
            add_obj = findobj('Tag','Add protocol dropmenu');
            insert_obj = findobj('Tag','Insert protocol dropmenu');
            protocol_to_add = add_obj.String(add_obj.Value);
            
            %add the protocol
            for p = 1:length(self.protocol_types)
                if strcmp(protocol_to_add, self.protocol_types{p}.sProtocolName)
                    new_protocol = RealtimeProtocol(1,self.protocol_types{p},self.sampling_frequency);
                    break;
                end
            end
            
            
            %update the figure
            protocols_names_obj = findobj('Tag', 'Protocol name text');
            protocols_names = {};
            for pn = length(protocols_names_obj):-1:1
                protocols_names = [protocols_names {protocols_names_obj(pn).String}];
            end
            
            protocols_durations_obj = findobj('Tag', 'Protocol duration text');
            protocols_durations = {};
            for pd = length(protocols_durations_obj):-1:1
                protocols_durations = [protocols_durations {protocols_durations_obj(pd).String}];
            end
            %!!!!
            pr_idx = strsplit(insert_obj.String{insert_obj.Value});
            idx = str2num(pr_idx{1}); %#ok<ST2NM>
            protocols_names = [protocols_names(end:-1:idx+1) new_protocol.protocol_name protocols_names(idx:-1:1)];
            protocols_names = protocols_names(end:-1:1);
            protocols_durations = [protocols_durations(end:-1:idx+1) num2str(new_protocol.protocol_duration) protocols_durations(idx:-1:1)];
            protocols_durations = protocols_durations(end:-1:1);
            self.UpdateEditProtocolsFigure(protocols_names,protocols_durations);
        end
        function DeleteProtocol(self,obj,event) %#ok<INUSD>
            delete_obj = findobj('Tag','Delete protocol dropmenu');
            
            protocols_names_obj = findobj('Tag', 'Protocol name text');
            protocols_names = {};
            for pn = length(protocols_names_obj):-1:1
                protocols_names = [protocols_names {protocols_names_obj(pn).String}];
            end
            
            protocols_durations_obj = findobj('Tag', 'Protocol duration text');
            protocols_durations = {};
            for pd = length(protocols_durations_obj):-1:1
                protocols_durations = [protocols_durations {protocols_durations_obj(pd).String}];
            end
            
            protocols_names = [protocols_names(1:delete_obj.Value+self.next_protocol-2) protocols_names(delete_obj.Value+self.next_protocol:end)];
            protocols_durations = [protocols_durations(1:delete_obj.Value+self.next_protocol-2) protocols_durations(delete_obj.Value+self.next_protocol:end)];
            self.UpdateEditProtocolsFigure(protocols_names,protocols_durations);
        end
        function UpdateEditProtocolsFigure(self,protocols_names,protocols_durations)
            protocol_figure = findobj('Tag', 'EditProtocolFigure');
            old_names = findobj('Tag', 'Protocol name text');
            old_durations = findobj('Tag', 'Protocol duration text');
            old_count = findobj('Tag', 'Protocol count');
            old_ms = findobj('Tag','s text');
            
            delete (old_names);
            delete (old_durations);
            delete (old_count);
            delete(old_ms);
            
            max_height = protocol_figure.Position(4) - 0.05;
            %mind the numbers
            
            self.protocol_duration_text = {};
            for p = 1:length(protocols_names)
                bgr = 0.94-[0.1 0.1 0.1] * mod(p-1,2);
                protocol_count{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.01,max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(p),'HorizontalAlignment','left','Tag','Protocol count','BackgroundColor',bgr);
                protocol_name{end+1} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.04,max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.25, protocol_figure.Position(4)*0.04],'String', protocols_names{p},'HorizontalAlignment','left','Tag','Protocol name text','BackgroundColor',bgr);
                if p < self.next_protocol %already recorded; duration cannot be changed
                    self.protocol_duration_text{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.3, max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(protocols_durations{p}),'Tag','Protocol duration text','HorizontalAlignment','right');
                else
                    self.protocol_duration_text{p} = uicontrol('Parent',protocol_figure,'Style','edit','Position', [protocol_figure.Position(3)*0.3, max_height-protocol_figure.Position(4)*0.05*p, protocol_figure.Position(3)*0.05, protocol_figure.Position(4)*0.04],'String', num2str(protocols_durations{p}),'HorizontalAlignment','right','Tag', 'Protocol duration text');
                end
                ms{p} = uicontrol('Parent',protocol_figure,'Style','text','Position', [protocol_figure.Position(3)*0.35,max_height-protocol_figure.Position(4)*0.05*p,protocol_figure.Position(3)*0.02 , protocol_figure.Position(4)*0.04],'String', 's','HorizontalAlignment','left','BackgroundColor',bgr,'Tag','s text');
                
            end
            %update dropmenus
            insert_protocol_dropmenu = findobj('Tag','Insert protocol dropmenu');
            delete_protocol_dropmenu = findobj('Tag','Delete protocol dropmenu');
            new_protocols_names = cell(1,length(protocols_names));
            for i = self.next_protocol-1:length(protocols_names)
                if i < 1
                    continue;
                end
                pn = protocols_names(i);
                new_protocols_names(i) = {[num2str(i) ' ' pn{1}]};
            end
            if self.next_protocol == 1
                insert_protocol_dropmenu.String = [{'0'} new_protocols_names];
            else
                insert_protocol_dropmenu.String = new_protocols_names; %%%%delete prt dropmenu
            end
            delete_protocol_dropmenu.String = new_protocols_names;
            
            
            
        end
        function ChangeProtocols(self,obj,event) %#ok<INUSD>
            %get the protocols
            self.feedback_protocols(self.next_protocol:end) = [];
            protocols_names_obj = findobj('Tag', 'Protocol name text');
            protocols_durations_obj = findobj('Tag', 'Protocol duration text');
            for j = length(protocols_names_obj)-self.next_protocol+1:-1:1
                for i = 1:length(self.protocol_types)
                    if strcmp(protocols_names_obj(j).String,self.protocol_types{i}.sProtocolName)
                        rtp = RealtimeProtocol(1,self.protocol_types{i});
                        rtp.protocol_duration = str2double(protocols_durations_obj(j).String);  %%%%%duration is taken from the figure
                        rtp.Recalculate(self.sampling_frequency,self.fb_refresh_rate);
                        self.feedback_protocols{end+1} = rtp;
                        break;
                    end
                end
            end
            %check if we reserved enough space
            data_length = 0;
            for p = 1:length(self.feedback_protocols)
                data_length = data_length + self.feedback_protocols{p}.protocol_size;
            end
            if fix(data_length*1.5)> self.exp_data_length
                
                self.exp_data_length = fix(data_length*1.5);
                for ds = 1:length(self.derived_signals)
                    new_circbuff = circVBuf(self.exp_data_length, size(self.derived_signals{ds}.collect_buff.raw,2),0);
                    new_circbuff.append(self.derived_signals{ds}.collect_buff.raw(self.derived_signals{ds}.collect_buff.fst:self.derived_signals{ds}.collect_buff.lst,:));
                    self.derived_signals{ds}.collect_buff = new_circbuff;
                end
                new_fb_records = circVBuf(self.exp_data_length,7,0);
                if ~isempty(self.feedback_manager.feedback_records)
                    new_fb_records.append(self.feedback_manager.feedback_records.raw(self.feedback_manager.feedback_records.fst:self.feedback_manager.feedback_records.lst,:));
                    self.feedback_manager.feedback_records = new_fb_records;
                end
            end
            
            %delete the figure
            delete(obj.Parent);
        end
        % для сохранения в файл
        function ExpDesignToXML(self)
            curr_date = datestr(date,29);
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
            end
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
            end
            
            %prepare xml
            self.exp_design = struct();
            vSignals = struct();
            for ds = 1:length(self.derived_signals)
                if ds > 1
                    vSignals.DerivedSignal(ds).fAverage = self.feedback_manager.average(ds-1);
                    vSignals.DerivedSignal(ds).fStdDev = self.feedback_manager.standard_deviation(ds-1);
                end
                vSignals.DerivedSignal(ds).sSignalName = self.derived_signals{ds}.signal_name;
                
                try %#ok<TRYNC>
                    vSignals.DerivedSignal(ds).fBandpassLowHz = self.derived_signals{ds}.temporal_filter{1}.range(1);
                    vSignals.DerivedSignal(ds).fBandpassHighHz = self.derived_signals{ds}.temporal_filter{1}.range(2);
                end
                
                try %#ok<TRYNC>
                    vSignals.DerivedSignal(ds).sType = self.derived_signals{ds}.signal_type;
                end
                %prepare spatial filter matrix
                spatial_filter_matrix_struct = struct();
                for ch = 1:size(self.derived_signals{ds}.channels,1)
                    s = '';
                    for i = 2:size(self.derived_signals{ds}.channels,2)
                        s = [s, ',', num2str(self.derived_signals{ds}.channels{ch,i})];
                    end
                    s = s(2:end);
                    try
                        spatial_filter_matrix_struct.channels.(self.derived_signals{ds}.channels{ch,1}) =  s;
                    catch
                        2691 %#ok<NOPRT>
                    end
                end
                sp_filter_matrix = struct2xml(spatial_filter_matrix_struct);
                spf_filename = strcat(vSignals.DerivedSignal(ds).sSignalName,'.xml');
                vSignals.DerivedSignal(ds).SpatialFilterMatrix = spf_filename;
                %write the file
                spffile = fopen(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\',spf_filename),'w');
                fwrite(spffile,sp_filter_matrix);
                fclose(spffile);
                %vSignals.DerivedSignal(ds) = DS;
                
                %write statvalues
                sv = self.derived_signals{ds}.statvalues;
                save(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\',self.derived_signals{ds}.signal_name,'_statvalues.mat'),'sv');
            end
            
            vProtocols = struct();
            for p = 1:length(self.protocol_types)
                %copy all the fields
                fields = fieldnames(self.protocol_types{p});
                for j = 1: numel(fields)
                    %try %#ok<TRYNC>
                    vProtocols.FeedbackProtocol(p).(fields{j}) = self.protocol_types{p}.(fields{j});
                    %end
                end
            end
            vPSequence = struct();
            for fp = 1:length(self.feedback_protocols)
                vPSequence.s{fp} = self.feedback_protocols{fp}.protocol_name;
            end
            self.exp_design.NeurofeedbackSignalSpecs.vSignals = vSignals;
            self.exp_design.NeurofeedbackSignalSpecs.vProtocols = vProtocols;
            self.exp_design.NeurofeedbackSignalSpecs.vPSequence = vPSequence;
            self.exp_design.NeurofeedbackSignalSpecs.fSamplingFrequency = self.sampling_frequency;
            self.exp_design.NeurofeedbackSignalSpecs.bDoubleBlind = self.double_blind;
            self.exp_design.NeurofeedbackSignalSpecs.bShowFBCount = self.show_fb_count;
            self.exp_design.NeurofeedbackSignalSpecs.bShowFBRect = self.show_fb_rect;
            % necessary for formatting xml structures
            a = struct2xml(self.exp_design);
            
            design_file = fopen(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\Exp_design.xml'),'w');
            fwrite(design_file,a);
            fclose(design_file);
            disp(['Design file successfully written to the location ' strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\Exp_design.xml')]);
        end
        % уничтожает окно, сохраняет данные или нет
        function DoNothing(self,obj,event) %#ok<INUSD>
            %do nothing and destroy the window
            if nargin < 2 %destructor called from outside
                button = questdlg('You want to end the previous experiment and erase all the data?','End the experiment?', 'End and erase','Cancel','Cancel');
                switch button
                    case ''
                        
                    case 'Cancel'
                        
                    case 'End and erase'
                        if ~self.recorded && self.next_protocol > 1
                            answer = questdlg('Save the recorded data?','Save the recorded data?','Yes','No','Yes');
                            switch answer
                                case 'Yes'
                                    self.WriteToFile;
                            end
                        end
                        if ~isempty(self.timer_new_data)
                            
                            stop(self.timer_new_data);
                        end
                        if ~isempty(self.timer_disp)
                            stop(self.timer_disp);
                        end
                        if ~isempty(self.timer_fb)
                            stop(self.timer_fb);
                        end
                        self.inlet = [];
                        if ~isempty(self.raw_and_ds_figure) && isvalid(self.raw_and_ds_figure)
                            self.raw_and_ds_figure.CloseRequestFcn = 'closereq';
                            close(self.raw_and_ds_figure);
                        end
                        delete(self);
                        
                        
                end
            elseif strcmp(get(obj,'Tag'),'cancel_button')
                delete(obj.Parent);
                
            elseif strcmp(get(obj,'Tag'),'raw_and_ds_figure')
                button = questdlg('You want to end the experiment?','End the experiment?', 'Confirm','Cancel','Cancel');
                switch button
                    case ''
                    case 'Cancel'
                    case 'Confirm'
                        
                        stop(self.timer_new_data);
                        stop(self.timer_disp);
                        stop(self.timer_fb);
                        self.inlet = [];
                        if ~self.recorded  && self.next_protocol > 1
                            answer = questdlg('Save the recorded data?','Save the recorded data?','Yes','No','Yes');
                            switch answer
                                case 'Yes'
                                    self.WriteToFile;
                            end
                        end
                        
                        delete(obj);
                        
                        
                end
            else
                delete(obj);
            end
        end
        % запускает интерфейс позволяющий выбрать плохие каналы? (что за
        % плохие каналы) кнопка в function PlotEEGData
        function SelectBadChannels(self,obj,event) %#ok<INUSD>
            global finished;
            global ok;
            f = findobj('Tag','raw_and_ds_figure');
            epb = findobj('Tag','edit_protocols_button');
            select_btn = findobj('Tag','select_bad_channels_button');
            set(select_btn,'Visible','off');
            set(epb,'Visible','off');
            
            bad_channels_text =  uicontrol('Parent',f,'Style','text','String', self.bad_channels,'HorizontalAlignment','right','Tag','bad_channels_text');
            ok_button = uicontrol('Parent',f,'style','pushbutton', 'String', 'Add','Tag','add_bad_channel_button','Callback','global ok; ok = 1;');
            finished_button= uicontrol('Parent',f,'style','pushbutton', 'String', 'Finish','Tag','finish adding bad channels button','Callback','global ok; global finished; ok = 1;finished = 1;');
            text =  uicontrol('Parent',f,'Style','text','String', 'Select a channel and press Add','HorizontalAlignment','right','Tag','ch_text','HorizontalAlignment','center');
            datacursormode('off');
            r_sp = get(self.raw_subplot);
            self.FitFigure;
            finished = 0;
            while ~finished
                ok = 0;
                dcm_obj = datacursormode(f);
                set(dcm_obj,'UpdateFcn',@cursor_callback);
                %if 'OK'
                while ~(~isempty(getCursorInfo(dcm_obj)) && ok)
                    datacursormode('on');
                    pause(1);
                    if ok && isempty(getCursorInfo(dcm_obj))
                        ok = 0;
                    end
                    if finished
                        break; %#ok<UNRCH>
                    end
                    
                end
                if ~finished
                    datacursormode('off');
                    cursor_info = getCursorInfo(dcm_obj);
                    self.bad_channels{end+1} = cursor_info.Target.DisplayName;
                    self.bad_channels = unique(self.bad_channels);
                    set(bad_channels_text,'String',self.bad_channels);
                    dcm_obj.removeAllDataCursors();
                end
            end
            delete(ok_button);
            delete(finished_button);
            delete(findobj('Tag','bad_channels_text'));
            delete(text);
            datacursormode('off');
            set(epb,'Visible','on');
            set(select_btn,'Visible','on');
            %update derived signals
            
            for b_ch = 1:length(self.bad_channels)
                for child = 1:length(r_sp.Children)
                    try
                        if strcmp(self.bad_channels{b_ch},r_sp.Children(length(r_sp.Children)-child+1).DisplayName)
                            self.raw_data_indices = self.raw_data_indices(self.raw_data_indices ~= child);
                            
                        end
                    catch
                        length(r_sp.Children)
                        child %#ok<NOPRT>
                    end
                end
            end
            for ds = 1:length(self.derived_signals)
                self.derived_signals{ds}.ZeroOutBadChannels(self.bad_channels);
            end
            %update  YTickLabels
            for b_ch = 1:length(self.bad_channels)
                self.r_ytick_labels(strcmp(self.bad_channels{b_ch},self.r_ytick_labels)) = [];
            end
            %update shift
            r_temp = zeros(length(self.raw_data_indices),fix(self.plot_size));
            self.raw_plot = plot(r_temp', 'Parent', self.raw_subplot);
            for i = 2:length(self.r_ytick_labels)-1
                set(self.raw_plot(i-1),'DisplayName',self.r_ytick_labels{i});
            end
            %and set them
            set(self.raw_subplot,'YLim',[0 self.raw_shift*length(self.r_ytick_labels)]);
            self.FitFigure;
            
        end
        % использует LDA, не используется закоментированная строка в Receive
        function PrepareLearning(self)
            if ~isempty(self.inlet)
                self.inlet.close_stream();
            end
            stop(self.timer_new_data);
            stop(self.timer_disp);
            stop(self.timer_fb);
%             
            %%% select the protocols
            csp_figure = figure('Tag','CSP choice');
            max_height = csp_figure.Position(4)-csp_figure.Position(4)*0.1;
            select_baseline_protocol = uicontrol('Parent', csp_figure,'Style','text','Position',[csp_figure.Position(3)*0.12,csp_figure.Position(4)*0.85, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.1],...
                'Tag','select_baseline_protocol_text','String','Select Baseline','FontSize',11,'HorizontalAlignment','center');
            select_other_protocols = uicontrol('Parent', csp_figure,'Style','text','Position',[csp_figure.Position(3)*0.62,csp_figure.Position(4)*0.85, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.1],...
                'Tag','select_baseline_protocol_text','String','Select protocols to CSP','FontSize',11,'HorizontalAlignment','center');
            
            protocol_rbgroup = uibuttongroup('Parent',csp_figure,'Position',[0.08 0.1 .3 0.76]);
            if self.ssd < self.next_protocol -1
                next_protocol = self.next_protocol -1;
            else
                next_protocol = self.ssd;
            end
            
            for pr = 1:next_protocol-1
                bgr = ones(1,3) * 0.94; %default background colo
                %bgr = 0.94-[0.1 0.1 0.1] * mod(pr-1,2); %background color
                first_pr{pr} = uicontrol(protocol_rbgroup,'Style','radiobutton','String',self.feedback_protocols{pr}.show_as,'Position',[csp_figure.Position(3)*0.05,max_height-csp_figure.Position(4)*0.15-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.05],'HandleVisibility','off');
                second_pr{pr} = uicontrol('Parent',csp_figure,'Style','radiobutton','Position',[csp_figure.Position(3)*0.45,max_height-csp_figure.Position(4)*0.04-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'Tag','protocols_chb','BackgroundColor',bgr,'Callback',@self.CheckIfSelected,'String',self.feedback_protocols{pr}.show_as);
                edit_name{pr} = uicontrol('Parent',csp_figure,'Style','edit','Position', [csp_figure.Position(3)*0.65,max_height-csp_figure.Position(4)*0.04-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'String', self.feedback_protocols{pr}.show_as,'HorizontalAlignment','left','Tag','Edit name text');
            end
            okay_button = uicontrol('Parent',csp_figure,'Style','pushbutton','Position', [csp_figure.Position(3)*0.75,csp_figure.Position(4)*0.05, csp_figure.Position(3)*0.09,csp_figure.Position(4)*0.12],'String', 'OK','Tag','okay_button','Callback','uiresume','enable','off');
            uiwait();
            
            data_sets = {};
            data_names = {};
            if ~ishandle(csp_figure)
                return
            else
                
                for pr = 1:next_protocol-1
                    %fetch baseline data
                    if get(first_pr{pr},'Value')
                        idx1 = self.protocol_indices(pr,1);
                        idx2 = self.protocol_indices(pr,2);
                        fst_data = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                        fst_length = length(fst_data);
                        fst_edited = fst_data;
                        data_pwr = sqrt(sum((fst_data.^2),2));
                        bl = 1;
                        while length(fst_edited) > 0.95*fst_length && bl < 7
                            %for  n = 1 : 3
                            Xmean = mean(data_pwr);
                            Xstd = std(data_pwr);
                            mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
                            idx = find(mask);
                            fst_edited = fst_edited(idx,:);
                            data_pwr = data_pwr(idx,:);
                            bl = bl+1;
                            %length(idx)
                        end
                        % self.derived_signals{1}.statvalues = fst_edited;
                        %self.baseline_protocol = pr;
                        fst_name = self.feedback_protocols{pr}.show_as;
                    end
                    %fetch csp data
                    if get(second_pr{pr},'Value')
                        idx1 = self.protocol_indices(pr,1);
                        idx2 = self.protocol_indices(pr,2);
                        %check data length
                        snd_data = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                        snd_length = length(snd_data);
                        snd_edited = snd_data;
                        data_pwr = sqrt(sum((snd_edited.^2),2));
                        csp = 1;
                        %for  n = 1 : 3
                        while length(snd_edited) > 0.95*snd_length && csp < 7
                            Xmean = mean(data_pwr);
                            Xstd = std(data_pwr);
                            mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
                            idx = find(mask);
                            snd_edited = snd_edited(idx,:);
                            data_pwr = data_pwr(idx,:);
                            %length(idx)
                            csp = csp +1;
                        end
                        
                        % data_sets{end+1} = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                        %snd_set = snd_edited;
                        snd_name = get(edit_name{pr},'String');
                        
                    end
                    
                end
                delete(csp_figure);
            chs = SelectChannelsForCSP(self, snd_name);
            fst_edited = self.ReduceDataSet(fst_edited,chs);
            snd_edited = self.ReduceDataSet(snd_edited,chs);

                
                %d = 1;
                %self.csp_chs{d} = self.SelectChannelsForCSP(data_names{d});
                %bl_data_set = self.ReduceDataSet(baseline_data,self.csp_chs{d});
                %csp_data_set = self.ReduceDataSet(data_sets{d},self.csp_chs{d});
                %self.CalculateCSP(bl_data_set,csp_data_set,baseline_name, data_names{d},self.csp_chs{d});
      
                self.LDA(fst_edited,snd_edited,fst_name,snd_name,chs);
                self.ds_ylabels_fixed = 0;
                if strcmp(self.timer_new_data.Running,'off')
                        self.inlet = lsl_inlet(self.streams{1});
                        self.InitTimer();
                    end
        
                %                 while d < length(data_sets)
                %
                %                     waitfor(findobj('Tag','heads_figure'));
                %                     d = d + 1;
                %                     self.csp_chs{d} = self.SelectChannelsForCSP(data_names{d});
                %                     bl_data_set = self.ReduceDataSet(baseline_data,self.csp_chs{d});
                %                     csp_data_set = self.ReduceDataSet(data_sets{d},self.csp_chs{d});
                %                     self.CalculateCSP(bl_data_set,csp_data_set, data_names{d},self.csp_chs{d});
                %
                %                 end
                
                
                %write stats to file
                %                 head_str = 'N, protocol_name, protocol_show_as';
                %                 st = [num2str(self.baseline_protocol) ' ' self.feedback_protocols{self.baseline_protocol}.protocol_name ' ' self.feedback_protocols{self.baseline_protocol}.show_as];
                %                 for ds = 2:length(self.derived_signals)
                %                     head_str = [head_str ', ' self.derived_signals{ds}.signal_name ' av, ' self.derived_signals{ds}.signal_name ' std'];
                %                     st = [st ' ' num2str(self.feedback_manager.average(ds-1)) ' ' num2str(self.feedback_manager.standard_deviation(ds-1))];
                %                 end
                %
                %                 curr_date = datestr(date,29);
                %                 if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                %                     mkdir(strcat(self.path,'\',self.subject_record.subject_name));
                %                 end
                %                 if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                %                     mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
                %                 end
                %                 if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                %                     mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
                %                 end
                %
                %                 filename = strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',...
                %                     self.subject_record.time_start,'\','Update_Stats.txt');
                %                 if ~exist(filename,'file')
                %                     f = fopen(filename,'w');
                %                     fprintf(f, head_str);
                %                     fprintf(f,'\n');
                %                 else
                %                     f = fopen(filename,'a');
                %                 end
                %                 st = [st '\n'];
                %                 fprintf(f,st);
                %                 fclose(f);
                
                %written
            end
            
            
        end
        % Линейный дискриминантный анализ (тесно связан с методом главных компонент)
        function LDA(self,fst,snd,fst_name,snd_name,chs)
            try
            all_d = [fst' snd'];
            i = 1;
            
            for f0 = 8:0.5:20
                pp(1,:) = [f0-3,f0-1];
                pp(2,:) = [f0-1, f0+1];
                pp(3,:) = [f0+1, f0+3];
                for f = 1:3
                    [z, p, k] = cheby1(3,1,pp(f,:)/(0.5*self.sampling_frequency),'bandpass');
                                 [b,a] = zp2tf(z,p,k);
                    %flt = CreateFilter(pp(f,:),1000);
                    %x = filtfilt(flt,all(:,5*self.sampling_frequency:end-5*self.sampling_frequency)')';
                    x = filtfilt(b,a,all_d(:,5*self.sampling_frequency:end-5*self.sampling_frequency)')';
                    C{f} = x*x'/size(x,2);
                    C{f} = C{f} * 0.1*trace(C{f})/size(C{f},1)*eye(size(C{f}));
                end
                try
                    [v e] = eig(C{2},0.5 * (C{1} + C{3}),'chol');
                    [u,s,v] = svd((C{1} + C{3})^(-1)*C{2});
                    %[mxv, mxi] = max(diag(e));
                    mxi = 1;
                    mxv = s(1,1);
                    SSD(i) = mxv;
                    V(:,i) = u(:,mxi);
                    G(:,i) = u(mxi,:);
                    Fr(i) = f0; %frequencies
                    Rng(i,:) = pp(2,:); % band
                    i = i+1;
                catch
                    3081
                end
            end
            hh = figure;
            plot(Fr,SSD); xlabel('frequency, Hz');
            annotation('textbox', [0.2,0.8,0.1,0.1],'String', {'Two left clicks and Enter to select range.','Backspace to delete last point','Right click to finish'});
            
            F = getpts(hh);
            if length(F) == 1
                %peaks_found = 1;
                close(hh);
                %break;
            end
            close(hh);
        
        left_point = min(F);
        right_point = max(F);
        
        ind = find(Fr>=left_point & Fr<=right_point);
        [~, ind_max] = max(SSD(ind));
        middle_point = ind(ind_max);
        disp(strcat(num2str(Fr(middle_point)),' Hz'));
        channel_mapping = figure;
        stem(G(:,middle_point));
        set(get(channel_mapping,'Children'),'XTick',(1:1:length(chs)));
        set(get(channel_mapping,'Children'),'XTickLabel',chs);
        init_band = [Fr(middle_point)-1 Fr(middle_point)+1];
        self.init_band(end+1) = init_band;
        
        hh1 = figure; 
        StandChannels = load('StandardEEGChannelLocations.mat');
        try
        rearranged_map = rearrange_channels(G(:,middle_point),self.used_ch, StandChannels.channels);
        catch
            'There is no info for some channels' %#ok<NOPRT>
        end
        topoplot(rearranged_map, StandChannels.channels, 'electrodes', 'labelpoint', 'chaninfo', StandChannels.chaninfo);
            catch
                %init_band = [6 14];
                %disp('SSD was unsuccessful.Setting init_band to [6 14]');
            end
        for ib = 1:1
            band = init_band + ib - 1;
            flt = CreateFilter(band,self.sampling_frequency);
            filtered_fst = filtfilt(flt,fst)';
            filtered_snd = filtfilt(flt,snd)';
            filtered_fst = filtered_fst(:,5*self.sampling_frequency:end-5*self.sampling_frequency);
        filtered_snd = filtered_snd(:,5*self.sampling_frequency:end-5*self.sampling_frequency);
        all_d = [fst(5*self.sampling_frequency:end-5*self.sampling_frequency,:)' snd(5*self.sampling_frequency:end-5*self.sampling_frequency,:)'];
        
            filtered_all = filtfilt(flt,all_d')';
            C10 = filtered_fst * filtered_fst'/fix(size(filtered_fst,2));
            C20 = filtered_snd * filtered_snd'/fix(size(filtered_snd,2));
            nchan = size(C10,1);
            %%regularize covariances
            %%%%%%%%%%%%%%%%%%%%%%
            try
                C1 = C10 + self.lambda * trace(C10) * eye(nchan) / nchan;
                
                C2 = C20 + self.lambda * trace(C20) * eye(nchan) / nchan;
            catch
                3137 %#ok<NOPRT>
            end
            %%do generalized eigenvalue decomp
            [Vfs, dfs] = eig(C1,C2);
            [Vsf, dsf] = eig(C2,C1);
            % iV = inv(V);
            %                 M12{ib} = V(:,[1:Ncomp, end-Ncomp+1:end])';
            %                 G12{ib} = iV([1:Ncomp, end-Ncomp+1:end],:);
            %                 eigvs = diag(d)';
            %                  diags(ib,:) = eigvs([1:Ncomp end-Ncomp+1:end]);
            W = [Vfs(:,1) Vfs(:,end) Vsf(:,1) Vsf(:,end)];
            Z = W' * filtered_all;
            clear Zc;
            for k = 1:size(W,2)
                Zc(k,:) = conv(ones(1,self.sampling_frequency),Z(k,:).^2);
            end
            S = ones(1,size(Z,2));
            S(1:size(filtered_fst,2)) = 1;
            S(size(filtered_fst,2)+1:end) = 2;
            figure;
            obj = train_shrinkage(Zc',S' );
            W12 = obj.W;
            U = W12'*Zc; %control signal
            s = W12'*Zc - mean(W12'*Zc);
            plot(W12'*Zc);
            hold on;
            plot(s);
            
            grid
            hold on;
            

            %plot([1 length(W12'*Zc)],[ones(1,2)*(mean(abs(s)-mean(W12'*Zc)))]);
            hold on;
            plot([1 length(W12'*Zc)], [ std(W12'*Zc) std(W12'*Zc)]);
            plot([1 length(W12'*Zc)], [ -std(W12'*Zc) -std(W12'*Zc)]);
            %plot([1 length(W12'*Zc)],[ones(1,2)*(-mean(abs(s)-mean(W12'*Zc)))]);
            self.lda_threshold = mean(abs(W12'*Zc));
        end
        signal_name = [snd_name ' vs ' fst_name];
        w_ssd = W';
        
        if nargin > 5
            chan_w = cell(length(self.derived_signals{1}.channels),size(w_ssd,1)+1);
            for kkk = 1:size(chan_w,1)
                for jjj = 2:size(chan_w,2)
                    chan_w{kkk,jjj} = 0;
                end
            end
            for i=1:length(w_ssd)
                for ch = 1:length(self.derived_signals{1}.channels)
                    for ind = 2:size(w_ssd,1)+1
                        chan_w{ch,1} = self.derived_signals{1}.channels{ch};
                        if strcmp(self.derived_signals{1}.channels{ch},chs{i})
                            %self.derived_signals{1}: the first DS is ALWAYS RAW signal
                            try
                            chan_w{ch,ind} = w_ssd(ind-1,i);
                            catch
                                2
                            end
                            continue ;
%                         else
%                            
%                             try
%                             if all(size(chan_w) == [ 1 1]) || isempty(chan_w{ch,ind-1})
%                                 chan_w{ch,ind} = 0;
%                             end
%                             catch
%                                 1
%                             end
                        end
                    end;
                end
            end
            
        
        end
        self.derived_signals{end+1} = self.CreateNewDS(signal_name,chan_w,init_band,signal_name);
            
        self.derived_signals{end}.signal_type = 'combined';
        self.feedback_type = 1; %lda
        
        %%%SSD
        
        
        
        
        %b_ssd = B(middle_point,:);
        %a_ssd = A(middle_point,:);
        
        %update_stats
        self.derived_signals{end}.statvalues = filtered_all'*W;
        %end
        self.feedback_manager.average(length(self.derived_signals)-1) = mean(sum(abs(self.derived_signals{end}.statvalues),2));
        self.feedback_manager.standard_deviation(length(self.derived_signals)-1) = std(sum(abs(self.derived_signals{end}.statvalues),2));
        if ~self.fb_manager_set
        self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
        self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
        
        self.fb_manager_set = 1;
        end
        self.fb_statistics_set = 1;
        disp('Stats updated')
        
        
        
        end
        % запускает интерфес для выбора каналов ээг которые будут использованы в пространственном фильтре 
        function selected_channels = SelectChannelsForCSP(self, csp_name)
    if nargin < 2
        csp_name = 'CSP';
    end
    f =figure;
    title = uicontrol('Parent',f,'Style','text','String',csp_name,'units','normalized','Position',[0.4 0.9 0.2 0.05]);
    all_ch_text = uicontrol('Parent',f,'Style','text','String','All channels','units','normalized','Position',[0.1 0.9 0.2 0.05]); %#ok<*NASGU>
    selected_ch_text = uicontrol('Parent',f,'Style','text','String','Selected channels','units','normalized','Position',[0.7 0.9 0.2 0.05]);
    left_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Left','Position', [0.38 0.8 0.1 0.1],'Tag','select_left_ch','Callback',@SelectChannels);
    center_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Center','Position', [0.46 0.8 0.1 0.1],'Tag','select_center_ch','Callback',@SelectChannels);
    right_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Right','Position', [0.56 0.8 0.1 0.1],'Tag','select_right_ch','Callback',@SelectChannels);
    all_ch = uicontrol('Parent',f,'Style','listbox','Min',0,'Max',32,'units','normalized','Position',[0.05 0.1 0.3 0.8],'String',self.channel_labels,'Tag','all ch list');
    selected_ch = uicontrol('Parent',f,'Style','listbox','Min',0,'Max',32,'units','normalized','Position',[0.66 0.1 0.3 0.8],'String',{},'Tag','selected ch list');
    select_btn = uicontrol('Parent',f,'Style','pushbutton','String','>>','units','normalized','Position',[0.45 0.75 0.1 0.05],'Tag','select_btn','Callback',@SelectChannels);
    deselect_btn = uicontrol('Parent',f,'Style','pushbutton','String','<<','units','normalized','Position',[0.45 0.65 0.1 0.05],'Tag','deselect_btn','Callback',@SelectChannels);
    okay_btn = uicontrol('Parent',f,'Style','pushbutton','String','Done','units','normalized','Position',[0.41 0.03 0.18 0.06],'Tag','okay_btn','Callback','uiresume');
    if strfind(title.String,'right')
        right_chb.Value = 1;
        SelectChannels(right_chb);
    end
    if strfind(title.String,'left')
        left_chb.Value = 1;
        SelectChannels(left_chb);
    end
    uiwait()
    
    selected_channels = selected_ch.String;
    close(f);
    
        end
        % оставляет в выходном векторее ээг только нужные каналы
        function reduced_data_set = ReduceDataSet(self,data_set,chs)
    [truefalse, indices] = ismember(chs,self.channel_labels); %#ok<ASGLU>
    reduced_data_set = data_set(:,indices);
    
        end
        % 
        function [baseline_data, data_sets, data_names] = Prepare_CSP(self)
            %stop the timers
            if ~isempty(self.inlet)
                self.inlet.close_stream();
            end
            stop(self.timer_new_data);
            stop(self.timer_disp);
            stop(self.timer_fb);
            
            %count csp protocols
            csps = 0;
            if self.next_protocol > length(self.feedback_protocols)
                next_protocol = length(self.feedback_protocols);
            elseif self.ssd < self.next_protocol -1
                next_protocol = self.next_protocol -1;
            else
                next_protocol = self.ssd;
            end
            
            for pr = 1:next_protocol
                if strfind(lower(self.feedback_protocols{pr}.protocol_name),'csp')
                    csps = csps + 1;
                end
            end
            while true
                waitfor(findobj('Tag','CSP choice'));
                waitfor(findobj('Tag','heads_figure'));
                
                %%list the previous protocols and allow to checkbox those
                %%that are supposed to be calculated
                csp_figure = figure('Tag','CSP choice');
                max_height = csp_figure.Position(4)-csp_figure.Position(4)*0.1;
                select_baseline_protocol = uicontrol('Parent', csp_figure,'Style','text','Position',[csp_figure.Position(3)*0.12,csp_figure.Position(4)*0.85, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.1],...
                    'Tag','select_baseline_protocol_text','String','Select Baseline','FontSize',11,'HorizontalAlignment','center');
                select_other_protocols = uicontrol('Parent', csp_figure,'Style','text','Position',[csp_figure.Position(3)*0.62,csp_figure.Position(4)*0.85, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.1],...
                    'Tag','select_baseline_protocol_text','String','Select protocols to CSP','FontSize',11,'HorizontalAlignment','center');
                
                protocol_rbgroup = uibuttongroup('Parent',csp_figure,'Position',[0.08 0.1 .3 0.76]);
                
                
                for pr = 1:next_protocol
                    bgr = ones(1,3) * 0.94; %default background colo
                    %bgr = 0.94-[0.1 0.1 0.1] * mod(pr-1,2); %background color
                    protocol_rb{pr} = uicontrol(protocol_rbgroup,'Style','radiobutton','String',self.feedback_protocols{pr}.show_as,'Position',[csp_figure.Position(3)*0.05,max_height-csp_figure.Position(4)*0.15-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.2, csp_figure.Position(4)*0.05],'HandleVisibility','off');
                    protocol_chb{pr} = uicontrol('Parent',csp_figure,'Style','radiobutton','Position',[csp_figure.Position(3)*0.45,max_height-csp_figure.Position(4)*0.04-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'Tag','protocols_chb','BackgroundColor',bgr,'Callback',@self.CheckIfSelected,'String',self.feedback_protocols{pr}.show_as);
                    edit_name{pr} = uicontrol('Parent',csp_figure,'Style','edit','Position', [csp_figure.Position(3)*0.65,max_height-csp_figure.Position(4)*0.04-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'String', self.feedback_protocols{pr}.show_as,'HorizontalAlignment','left','Tag','Edit name text');
                end
                okay_button = uicontrol('Parent',csp_figure,'Style','pushbutton','Position', [csp_figure.Position(3)*0.75,csp_figure.Position(4)*0.05, csp_figure.Position(3)*0.09,csp_figure.Position(4)*0.12],'String', 'OK','Tag','okay_button','Callback','uiresume','enable','off');
                uiwait();
                
                %data_sets = {};
                %data_names = {};
                
                if ~ishandle(csp_figure)
                    return
                else
                    %%loop through protocols
                    for pr = 1:next_protocol
                        %fetch baseline data
                        if get(protocol_rb{pr},'Value')
                            idx1 = self.protocol_indices(pr,1);
                            idx2 = self.protocol_indices(pr,2);
                            baseline_data = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                            bl_length = length(baseline_data);
                            bl_edited = baseline_data;
                            data_pwr = sqrt(sum((baseline_data.^2),2));
                            bl = 1;
                            while length(bl_edited) > 0.95*bl_length && bl < 7
                                %for  n = 1 : 3
                                Xmean = mean(data_pwr);
                                Xstd = std(data_pwr);
                                mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
                                idx = find(mask);
                                bl_edited = bl_edited(idx,:);
                                data_pwr = data_pwr(idx,:);
                                bl = bl+1;
                                %length(idx)
                            end
                            self.derived_signals{1}.statvalues = bl_edited;
                            self.baseline_protocol = pr;
                            baseline_name = self.feedback_protocols{pr}.show_as;
                        end
                        %fetch csp data
                        if get(protocol_chb{pr},'Value')
                            idx1 = self.protocol_indices(pr,1);
                            idx2 = self.protocol_indices(pr,2);
                            %check data length
                            csp_data = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                            csp_length = length(csp_data);
                            csp_edited = csp_data;
                            data_pwr = sqrt(sum((csp_edited.^2),2));
                            csp = 1;
                            %for  n = 1 : 3
                            while length(csp_edited) > 0.95*csp_length && csp < 7
                                Xmean = mean(data_pwr);
                                Xstd = std(data_pwr);
                                mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
                                idx = find(mask);
                                csp_edited = csp_edited(idx,:);
                                data_pwr = data_pwr(idx,:);
                                %length(idx)
                                csp = csp +1;
                            end
                            
                            % data_sets{end+1} = self.derived_signals{1}.collect_buff.raw(self.derived_signals{1}.collect_buff.fst+idx1:self.derived_signals{1}.collect_buff.fst+idx2-1,:);
                            %data_sets{end+1} = csp_edited;
                            %data_names{end+1} = get(edit_name{pr},'String');
                            data_name = get(edit_name{pr},'String');
                        end
                        
                    end
                    delete(csp_figure);
                    %d = 1;
                    self.csp_chs{end+1} = self.SelectChannelsForCSP(data_name);
                    %self.csp_chs{d} = self.SelectChannelsForCSP(data_names{d});
                    bl_data_set = self.ReduceDataSet(baseline_data,self.csp_chs{end});
                    %csp_data_set = self.ReduceDataSet(data_sets{d},self.csp_chs{d});
                    csp_data_set = self.ReduceDataSet(csp_edited,self.csp_chs{end});
                    %self.CalculateCSP(bl_data_set,csp_data_set,baseline_name, data_names{d},self.csp_chs{d});
                    self.CalculateCSP(bl_data_set,csp_data_set,baseline_name, data_name,self.csp_chs{end});
                    %             while d < length(data_sets)
                    %
                    %                 waitfor(findobj('Tag','heads_figure'));
                    %                 d = d + 1;
                    %                 self.csp_chs{d} = self.SelectChannelsForCSP(data_names{d});
                    %                 bl_data_set = self.ReduceDataSet(baseline_data,self.csp_chs{d});
                    %                 csp_data_set = self.ReduceDataSet(data_sets{d},self.csp_chs{d});
                    %                 self.CalculateCSP(bl_data_set,csp_data_set, data_names{d},self.csp_chs{d});
                    %
                    %             end
                    
                    
                    %write stats to file
                    head_str = 'N, protocol_name, protocol_show_as';
                    st = [num2str(self.baseline_protocol) ' ' self.feedback_protocols{self.baseline_protocol}.protocol_name ' ' self.feedback_protocols{self.baseline_protocol}.show_as];
                    for ds = 2:length(self.derived_signals)
                        head_str = [head_str ', ' self.derived_signals{ds}.signal_name ' av, ' self.derived_signals{ds}.signal_name ' std'];
                        st = [st ' ' num2str(self.feedback_manager.average(ds-1)) ' ' num2str(self.feedback_manager.standard_deviation(ds-1))];
                    end
                    
                    curr_date = datestr(date,29);
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name));
                    end
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
                    end
                    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
                        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
                    end
                    
                    filename = strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',...
                        self.subject_record.time_start,'\','Update_Stats.txt');
                    if ~exist(filename,'file')
                        f = fopen(filename,'w');
                        fprintf(f, head_str);
                        fprintf(f,'\n');
                    else
                        f = fopen(filename,'a');
                    end
                    st = [st '\n'];
                    fprintf(f,st);
                    fclose(f);
                    
                    %written
                end
            end
        end
        % метод обертка для рассчета CSP фльтра
        function CalculateCSP(self,reduced_baseline_data,reduced_csp_data,baseline_name,data_name,channels)
    global selected
    global init_band
    global Ncomp
    global StandChannels
    %global bl_edited
    %global csp_edited
    
    
    %dir to write files
    curr_date = datestr(date,29);
    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
        mkdir(strcat(self.path,'\',self.subject_record.subject_name));
    end
    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date))
        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date));
    end
    if ~isdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start))
        mkdir(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
    end
    cd(strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start));
    
    if ~isfield(self.csp_settings,'iNComp') || isempty(self.csp_settings.iNComp)
        Ncomp = 2;
    else
        Ncomp = self.csp_settings.iNComp;
    end
    
    if ~isfield(self.csp_settings,'dInitBand') || isempty(self.csp_settings.dInitBand)
        init_band = self.init_band;
    else
        init_band = self.csp_settings.dInitBand;
    end
    %remove outliers
    %bl_edited = baseline_data;
    %csp_edited = csp_data;
    % bl_length = length(baseline_data);
    % csp_length = length(csp_data);
    %data_pwr = sqrt(sum((bl_edited.^2),2));
    % bl = 1;
    %csp = 1;
    %already done in Prepare_CSP
    %             while length(bl_edited) > 0.95*bl_length || bl < 7
    %                 %for  n = 1 : 3
    %                 Xmean = mean(data_pwr);
    %                 Xstd = std(data_pwr);
    %                 mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
    %                 idx = find(mask);
    %                 bl_edited = bl_edited(idx,:);
    %                 data_pwr = data_pwr(idx,:);
    %                 bl = bl+1;
    %                 %length(idx)
    %             end
    %
    
    %already done in Prepare CSP
    %             data_pwr = sqrt(sum((csp_edited.^2),2));
    %             %for  n = 1 : 3
    %             while length(csp_edited) > 0.95*csp_length || csp < 7
    %                 Xmean = mean(data_pwr);
    %                 Xstd = std(data_pwr);
    %                 mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
    %                 idx = find(mask);
    %                 csp_edited = csp_edited(idx,:);
    %                 data_pwr = data_pwr(idx,:);
    %                 %length(idx)
    %                 csp = csp +1;
    %             end
    
    
    %%present the heads
    hh1 = figure('Tag','heads_figure');
    StandChannels = load('StandardEEGChannelLocations.mat');
    ha = axes('Position',[0.1 0 0.75 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    okay_btn = uicontrol('Parent',hh1,'Style', 'pushbutton', 'String', 'OK', 'Callback', {@self.DSBasedOnCSP,reduced_baseline_data,channels},'Units','normalized', 'Position', [0.45 0.03 0.1 0.05],'Tag','SelectHeadsBtn','enable','off');
    
    %text(0.5, 1, data_name,'HorizontalAlignment','center','VerticalAlignment', 'top','Tag','dn','Units','normalized','Position',[ 0.45 0.1 0.1 0.05]);
    dn = uicontrol('Parent',hh1,'Style','text','Units','normalized','Position',[ 0.35 0.1 0.3 0.05],'Tag','dn','String',[data_name ' versus ' baseline_name]);
    lambda_text = uicontrol('Parent',hh1,'Style','text','Units','normalized','Position',[0.05 0.18 0.1 0.05],'String','Lambda');
    lambda_slider = uicontrol('Parent',hh1,'Style','slider','Units','normalized','Position',[0.15 0.18 0.4,0.05],'Callback',@self.ChangeLambda,'Tag','lambda_slider','Min',self.lambda_min,'Max',self.lambda_max,'Value',self.lambda,'SliderStep',[0.01 0.05]);
    lambda_edit = uicontrol('Parent',hh1,'Style','edit','Units','normalized','Position',[0.55 0.18 0.1 0.05],'Callback',@self.ChangeLambda,'Tag','lambda_edit','String',num2str(self.lambda));
    lambda_recalculate = uicontrol('Parent',hh1,'Style','pushbutton','Units','normalized','Position' ,[ 0.75 0.18 0.2 0.05], 'String','Recalculate','Callback',{@self.PresentCSPHeads,reduced_baseline_data,reduced_csp_data,channels},'Tag','recalculate_lambda');
    
    selected = {};
    
    self.PresentCSPHeads(1,1,reduced_baseline_data,reduced_csp_data,channels);
    %setting  figure title
    % savefig(gcf,strcat(self.path,'\',self.subject_record.subject_name,'\',curr_date,'\',self.subject_record.time_start,'\',data_name));
  
    %uiwait();
        end
        % вычисление производного сигнала с использованием CSP
        function DSBasedOnCSP(self,src,event,baseline_data,chan_names)  %#ok<INUSL>
    global selected
    global BandNumber
    global init_band
    global Ncomp
    global M12
    
    global Nmaps
    
    
    %forbid creating other user dialog windows
    ok_btn = findobj('Tag','SelectHeadsBtn');
    ok_btn.Enable = 'off';
    
    %%if the band is the same for all inputs, a choice is
    %offered whether to make one combined signal or
    %several; If the bands are different, no such
    %choice is offered
    %determine whether the band is the same
    dn = findobj('Tag','dn');
    data_name = dn.String;
    print(gcf,data_name,'-dpng','-noui');
    MapIndex = cellfun(@str2num,selected);
    BandNumber = fix((MapIndex-1)/(2*Ncomp))+1;
    CompNumber = mod(MapIndex-1,(2*Ncomp))+1;
    
    w_ssd = zeros(length(MapIndex),length(M12{1}));
    for bn = 1:length(MapIndex)
        w_ssd(bn,:) = M12{BandNumber(bn)}(CompNumber(bn),:);
    end
    
    signals_added = 0;
    if isempty(nonzeros(BandNumber - max(BandNumber))) && length(selected) > 1 %if it is empty, then all the bands are the same
        button = questdlg(['One combined DS or ', num2str(length(MapIndex)), ' different DS?'],'Choose the number of DS', 'One', num2str(length(MapIndex)),'One');
        if isempty(button) %is closed
            return
        elseif strcmp(button, 'One')
            %make one DS with 2-D sp_filter
            band = init_band + BandNumber(1)-1;
            chan_w = cell(length(self.derived_signals{1}.channels),size(w_ssd,1)+1);
            w_ssd = w_ssd';
            % 2-d spatial_filter
            %                     for i=1:length(w_ssd)
            %                         %self.derived_signals{1}: the first DS is ALWAYS RAW signal
            %                         chan_w{i,1} = self.derived_signals{1}.channels{i};
            %                         for ind = 2:size(w_ssd,2)+1
            %                             chan_w{i,ind} = w_ssd(i,ind-1);
            %                         end
            %
            %                     end;
            for i=1:length(w_ssd)
                for ch = 1:length(self.derived_signals{1}.channels)
                    for ind = 2:size(w_ssd,2)+1
                        chan_w{ch,1} = self.derived_signals{1}.channels{ch};
                        if strcmp(self.derived_signals{1}.channels{ch},chan_names{i})
                            %self.derived_signals{1}: the first DS is ALWAYS RAW signal
                            
                            chan_w{ch,ind} = w_ssd(i,ind-1);
                        else
                            if all(size(chan_w) == [ 1 1]) || isempty(chan_w{ch,ind})
                                chan_w{ch,ind} = 0;
                            end
                        end
                    end;
                end
            end
            clear chs
            chs(size(chan_w,1)) = struct();
            for ch = 1:size(chan_w,1)
                chs(ch).channel_name = chan_w{ch,1};
                coeff = '';
                for ind = 2:size(w_ssd,2)+1
                    coeff = [coeff ',' num2str(chan_w{ch,ind})];
                end
                
                chs(ch).coefficient = coeff(2:end);
            end
            
            
            
            sn = {''};
            while isempty(sn) || isempty(sn{1})
                sn = inputdlg('Enter derived signal name','Derived signal name',1,{strcat(data_name,'_CombinedDS_',num2str(band(1)),'-',num2str(band(2)))});
                ok_btn.Enable = 'on';
            end
            
            %%write spatial_filter to file
            if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                mkdir(strcat(self.path,'\',self.subject_record.subject_name));
            end
            pth = (strcat(self.path,'\',self.subject_record.subject_name));
            full_name = [pth '\CSP_' sn{1} '.xml'];
            
            if exist(full_name,'file')
                choice = questdlg('The spatial filter for this person already exists. Rewrite the filter?','Rewrite?','Yes','No, use the old one','No, use the old one');
                switch choice
                    case 'Yes'
                        chan_structure = struct();
                        chan_structure.channels.channel = chs;
                        x = struct2xml(chan_structure);
                        f = fopen(full_name,'w');
                        fwrite(f,x);
                        fclose(f);
                        spatial_filter = chan_w;
                    otherwise
                        s = xml2struct(full_name);
                        channels_coeff = cell(length(s.channels.channel),2);
                        for i = 1:length(s.channels.channel)
                            channels_coeff{i,1} = strtrim(s.channels.channel{i}.channel_name.Text);
                            coeffs = str2num(strtrim(s.channels.channel{i}.coefficient.Text)); %#ok<ST2NM>
                            for j = 2:length(coeffs)+1
                                channels_coeff{i,j} = coeffs(j-1);
                            end
                        end
                        %convert struct to cell!!
                        spatial_filter = channels_coeff;
                end
            else
                spatial_filter = chs;
                sp_filter_to_write = struct();
                sp_filter_to_write.channels = chs;
                x = struct2xml(sp_filter_to_write);
                f = fopen(full_name,'w');
                fwrite(f,x);
                fclose(f);
            end
            
            %%create DS
            %
            self.derived_signals{end+1} = CreateNewDS(self,sn{1},chan_w, band,full_name);
            self.derived_signals{end}.signal_type = 'combined';
            signals_added = 1;
            %%set fb
            
            %
            temp_derived_signal = CreateNewDS(self,'Temp',chan_w, band);
            %
            temp_derived_signal.signal_type = 'combined';
            %
            baseline_data = self.derived_signals{1}.statvalues;
            
            
            %already done
            %                     bl_length = length(baseline_data);
            %
            %                     data_pwr = sqrt(sum((baseline_data.^2),2));
            %
            %                     while length(baseline_data) > 0.95*bl_length
            %                         %for  n = 1 : 3
            %                         Xmean = mean(data_pwr);
            %                         Xstd = std(data_pwr);
            %                         mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
            %                         idx = find(mask);
            %                         baseline_data = baseline_data(idx,:);
            %                         data_pwr = data_pwr(idx,:);
            %                         %bl = bl+1;
            %                         %length(idx)
            %                     end
            %
            
            x = zeros(size(baseline_data,1),length(self.derived_signals{1}.spatial_filter));
            for i = 1:length(self.derived_signals{1}.spatial_filter)
                for j = size(baseline_data,2)
                    if self.derived_signals{1}.spatial_filter(i) && self.derived_signals{end}.spatial_filter(i)
                        x(:,i) = baseline_data(:,j);
                        %j = j+1;
                    else
                        x(:,i) = 0;
                    end
                end
            end
            
            temp_derived_signal.Apply(x',1);
            values = temp_derived_signal.collect_buff.raw(temp_derived_signal.collect_buff.fst:temp_derived_signal.collect_buff.lst,:);
            %calcuate feedback stats
            %values = abs(values);
            self.derived_signals{end}.statvalues = values;
            self.feedback_manager.average(length(self.derived_signals)-1) = mean(abs(values));
            self.feedback_manager.standard_deviation(length(self.derived_signals)-1) = std(abs(values));
            
            self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
            self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
            self.fb_manager_set = 1;
            
        end
    end
    
    %if no signals were added so far
    if ~signals_added
        for ind = 1:length(MapIndex)
            band = init_band + BandNumber(ind)-1;
            for i=1:length(w_ssd)
                for ch = 1:length(self.derived_signals{1}.channels)
                    
                    chan_w{ch,1} = self.derived_signals{1}.channels{ch};
                    if strcmp(self.derived_signals{1}.channels{ch},chan_names{i})
                        %self.derived_signals{1}: the first DS is ALWAYS RAW signal
                        
                        chan_w{ch,2} = w_ssd(ind,i);
                    else
                        if all(size(chan_w) == [ 1 1]) || isempty(chan_w{ch,2})
                            chan_w{ch,2} = 0;
                        end
                    end
                end;
            end
            
            %write to file
            try %write
                %convert cell chan_w to structure
                clear chs
                chs(size(chan_w,1)) = struct();
                for ch = 1:size(chan_w,1)
                    chs(ch).channel_name = chan_w{ch,1};
                    chs(ch).coefficient = chan_w{ch,2};
                end
                chan_structure = struct();
                chan_structure.channels.channel = chs;
                x = struct2xml(chan_structure);
                
                
                sn = {''};
                if CompNumber(ind) <= Nmaps/2
                    n = CompNumber(ind);
                else
                    n = CompNumber(ind)-Nmaps-1;
                end
                while isempty(sn)|| isempty(sn{1})
                    sn = inputdlg('Enter derived signal name','Derived signal name',1,{strcat(data_name,'_DS_', num2str(band(1)),'-',num2str(band(2)),'_',num2str(n))});
                    ok_btn.Enable = 'on';
                end
                
                if ~isdir(strcat(self.path,'\',self.subject_record.subject_name))
                    mkdir(strcat(self.path,'\',self.subject_record.subject_name));
                end
                pth = (strcat(self.path,'\',self.subject_record.subject_name));
                full_name = [pth '\CSP_' sn{1} '.xml'];
                if exist(full_name,'file')
                    choice = questdlg('The spatial filter for this person already exists. Rewrite the filter?','Rewrite?','Yes','No, use the old one','No, use the old one');
                    switch choice
                        case 'Yes'
                            f = fopen(full_name,'w');
                            fwrite(f,x);
                            fclose(f);
                            spatial_filter = chan_w;
                        otherwise
                            
                            s = xml2struct(full_name);
                            channels_coeff = cell(length(s.channels.channel),2);
                            for i = 1:length(s.channels.channel)
                                channels_coeff{i,1} = strtrim(s.channels.channel{i}.channel_name.Text);
                                channels_coeff{i,2} = str2double(strtrim(s.channels.channel{i}.coefficient.Text));
                            end
                            spatial_filter = channels_coeff;
                    end
                else
                    spatial_filter = chan_w;
                    f = fopen(full_name,'w');
                    fwrite(f,x);
                    fclose(f);
                end
                
                
            catch
                'Error while writing to file, function Calculate CSP' %#ok<NOPRT>
            end
            
            
            try
                
                %
                
                self.derived_signals{end+1} = CreateNewDS(self,sn{1},spatial_filter, band,full_name);
                
                %%temp derived signal to calculate stats
                temp_derived_signal = CreateNewDS(self,sn{1},spatial_filter, band);
                
                %%calculating stats
                %j = 1;
                %                         x = zeros(size(baseline_data,1),length(self.derived_signals{1}.spatial_filter));
                %                         for i = 1:length(self.derived_signals{1}.spatial_filter)
                %                             for j = size(baseline_data,2)
                %                             if self.derived_signals{1}.spatial_filter(i) && self.derived_signals{end}.spatial_filter(i)
                %                                 x(:,i) = baseline_data(:,j);
                %                                 %j = j+1;
                %                             else
                %                                 x(:,i) = 0;
                %                             end
                %                             end
                %                         end
                
                baseline_data = self.derived_signals{1}.statvalues;
                %
                %                         already done
                %
                %                         bl_length = length(baseline_data);
                %
                %                         data_pwr = sqrt(sum((baseline_data.^2),2));
                %
                %                         while length(baseline_data) > 0.95*bl_length
                %                             %for  n = 1 : 3
                %                             Xmean = mean(data_pwr);
                %                             Xstd = std(data_pwr);
                %                             mask = (abs(data_pwr-Xmean) < 2.5 * Xstd);
                %                             idx = find(mask);
                %                             baseline_data = baseline_data(idx,:);
                %                             data_pwr = data_pwr(idx,:);
                %
                %                             %length(idx)
                %                         end
                temp_derived_signal.Apply(baseline_data',1);
                values = temp_derived_signal.collect_buff.raw(temp_derived_signal.collect_buff.fst:temp_derived_signal.collect_buff.lst,:);
                %values = abs(values);
                self.derived_signals{end}.statvalues = values;
                self.feedback_manager.average(length(self.derived_signals)-1) = mean(abs(values));
                self.feedback_manager.standard_deviation(length(self.derived_signals)-1) = std(abs(values));
                
                
                
            catch
                'Error while creating a new derived signal, function CalculateCSP' %#ok<NOPRT>
            end
            
        end
        
        
        
        self.feedback_manager.feedback_vector = zeros(1,length(self.derived_signals)-1);
        self.feedback_manager.feedback_records = circVBuf(self.exp_data_length, self.fb_manager_size,0);
        self.fb_manager_set = 1;
    end
    self.protocol_indices(end,end+2) = 0;
    self.ds_ylabels_fixed = 0;
    close(findobj('Tag','heads_figure'));
    
        end
        % рассчет матрицы CSP фильтра
        function PresentCSPHeads(self,src, event,bl_edited, csp_edited,chan_labels) %#ok<INUSL>
    global init_band
    global Ncomp
    global StandChannels
    global M12
    global G12
    global Nmaps
    global selected
    lr = findobj('Tag','recalculate_lambda');
    %lr.String = 'Recalculating...';
    lr.Enable = 'off';
    
    %redraw
    selected = [];
    topoplots = findobj('Tag','topoplot');
    delete(topoplots);
    selections = findobj('Tag','Selection');
    delete(selections);
    
    diags = zeros(4,Ncomp*2); %4
    M12 = [];
    G12 = [];
    
    
    %%%%single csp
    
    
    for ib = 1:4
        band = init_band + ib - 1;
        flt = CreateFilter(band,self.sampling_frequency);
        filtered_bd = filtfilt(flt,bl_edited)';
        filtered_csp_d = filtfilt(flt,csp_edited)';
        C10 = filtered_bd * filtered_bd'/fix(size(filtered_bd,2));
        C20 = filtered_csp_d * filtered_csp_d'/fix(size(filtered_csp_d,2));
        nchan = size(C10,1);
        %%regularize covariances
        %%%%%%%%%%%%%%%%%%%%%%
        try
            C1 = C10 + self.lambda * trace(C10) * eye(nchan) / nchan;
            
            C2 = C20 + self.lambda * trace(C20) * eye(nchan) / nchan;
        catch
            3340 %#ok<NOPRT>
        end
        %%do generalized eigenvalue decomp
        [V, d] = eig(C1,C2);
        iV = inv(V);
        M12{ib} = V(:,[1:Ncomp, end-Ncomp+1:end])';
        G12{ib} = iV([1:Ncomp, end-Ncomp+1:end],:);
        eigvs = diag(d)';
        diags(ib,:) = eigvs([1:Ncomp end-Ncomp+1:end]);
    end
    
    
    %%%% double csp
    
    %             %%%CSP #1
    %             for ib = 1:4%4
    %                 band = init_band +ib-1 ;
    %                 %[z, p, k] = cheby1(3,1,band/(0.5*self.sampling_frequency),'bandpass');
    %                 %[b,a] = zp2tf(z,p,k);
    %                 flt = CreateFilter(band,self.sampling_frequency);
    %                 %designfilt('bandpassiir','StopbandFrequency1',1,'PassbandFrequency1',band(1),'PassbandFrequency2',band(2),...
    %                 % 'StopbandFrequency2', 50, 'StopbandAttenuation1',30,'PassbandRipple',1,'StopbandAttenuation2',30,'DesignMethod','cheby2','SampleRate', self.sampling_frequency);
    %                 filtered_bd = filtfilt(flt,bl_edited)';
    %                 filtered_csp_d = filtfilt(flt,csp_edited)';
    %                 C10 = filtered_bd * filtered_bd'/fix(size(filtered_bd,2));
    %                 C20 = filtered_csp_d * filtered_csp_d'/fix(size(filtered_csp_d,2));
    %                 nchan = size(C10,1);
    %                 %%regularize covariances
    %                 %%%%%%%%%%%%%%%%%%%%%%
    %                 try
    %                     C1 = C10 + self.lambda * trace(C10) * eye(nchan) / nchan;
    %
    %                     C2 = C20 + self.lambda * trace(C20) * eye(nchan) / nchan;
    %                 catch
    %                     3340 %#ok<NOPRT>
    %                 end
    %                 %%do generalized eigenvalue decomp
    %                 [V, d] = eig(C1,C2); %#ok<ASGLU>
    %                 iV = inv(V);
    %                 M12{ib} = V(:,[1:Ncomp, end-Ncomp+1:end])';
    %                 G12{ib} = iV([1:Ncomp, end-Ncomp+1:end],:);
    %
    %                 %find coefficients that >= mean and apply these to filtered data
    %                 %b_coeff = ones(Ncomp*2, min(size(bl_edited)));
    %                 b_coeff = abs(M12{ib}(1,:)) >= mean(abs(M12{ib}(1,:)));
    %                 bd_data{ib} = filtered_bd;
    %                 csp_data{ib} = filtered_csp_d;
    %                 for coefficient = b_coeff
    %                     if ~coefficient
    %                         bd_data{ib}(coefficient,:) = 0;
    %                         csp_data{ib}(coefficient,:) = 0;
    %                     end
    %                 end
    %                 %                 for component = 1:size(M12{ib},1)
    %                 %                     b_coeff(component,:) = abs(M12{ib}(component,:)) >= mean(abs(M12{ib}(component,:))); %%only the first is correct (?)
    %                 %                     bd_components_data{ib,component} = filtered_bd;
    %                 %                     csp_components_data{ib,component} = filtered_csp_d;
    %                 %                     for coefficient = 1:length(b_coeff(component,:))
    %                 %                         if ~b_coeff(component,coefficient)
    %                 %                             bd_components_data{ib,component}(coefficient,:) = 0;
    %                 %                             csp_components_data{ib,component}(coefficient,:) = 0;
    %                 %                         end
    %                 %                     end
    %                 %
    %                 %                 end
    %
    %             end
    %             %%%%CSP #2
    %             %
    %             for ib = 1:4
    %                 %for component = 1:size(M12{ib},1)
    %                 %C10 = bd_components_data{ib,component} * bd_components_data{ib,component}'/fix(size(bd_components_data{ib,component},2));
    %                 %C20 = csp_components_data{ib,component} * csp_components_data{ib,component}'/fix(size(csp_components_data{ib,component},2));
    %                 C10 = bd_data{ib} * bd_data{ib}' / fix(size(bd_data{ib},2));
    %                 C20 =csp_data{ib} * csp_data{ib}' / fix(size(csp_data{ib},2));
    %                 nchan = size(C10,1);
    %                 %%regularize covariances
    %                 %%%%%%%%%%%%%%%%%%%%%%
    %                 C1 = C10 + self.lambda * trace(C10) * eye(nchan) / nchan;
    %                 C2 = C20 + self.lambda * trace(C20) * eye(nchan) / nchan;
    %                 %%do generalized eigenvalue decomp
    %                 [V, d] = eig(C1,C2);
    %                 iV = inv(V);
    %                 M12{ib} = V(:,[1:Ncomp, end-Ncomp+1:end])';%%%%%%%%%%%%%%%!
    %                 G12{ib} = iV([1:Ncomp, end-Ncomp+1:end],:);%%%%%%%%%%%%%%%!
    %                 eigvs = diag(d)';
    %                 diags(ib,:) = eigvs([1:Ncomp end-Ncomp+1:end]);
    %                 %end
    %             end
    
    
    
    %chan_labels = self.used_ch(:,1)';
    Nbands = length(M12);
    PlotIndex = 1;
    
    for ib = 1:Nbands
        rearranged_map = rearrange_channels(M12{ib}',chan_labels, StandChannels.channels);
        Nmaps = size(rearranged_map,2);
        for tpm=1:Nmaps
            sp(PlotIndex) = subplot(Nbands+1,Nmaps,PlotIndex);
            if isreal(M12{ib})
                %                            topoplot(rearranged_map(:,tpm), StandChannels.channels, 'electrodes', 'labelpoint', 'chaninfo', StandChannels.chaninfo);
                topoplot(rearranged_map(:,tpm), StandChannels.channels,  'chaninfo', StandChannels.chaninfo);
                
                hold on;
                sibs = get(sp(PlotIndex),'Children');
                for k = 1:length(sibs)
                    
                    set(sp(PlotIndex).Children(k), 'ButtonDownFcn', @(src,event)toggleplot(src,event));
                    set(sp(PlotIndex).Children(k),'Tag','topoplot');
                end
            else
                0;
            end
            title([num2str(PlotIndex) ': ' num2str(diags(ib,tpm))]);
            %add legend
            PlotIndex = PlotIndex+1;
        end;
    end
    
    %lr.String = 'Recalculate';
    lr.Enable = 'on';
    
    
    
        end
        % 
        function ChangeLambda(self,src,event) %#ok<INUSD>
    
    if strcmp(src.Tag,'lambda_slider')
        self.lambda = src.Value;
        le = findobj('Tag','lambda_edit');
        le.String = num2str(src.Value);
    elseif strcmp(src.Tag,'lambda_edit')
        edit_value = str2double(src.String);
        if isnumeric(edit_value)
            if edit_value >= self.lambda_min && edit_value <= self.lambda_max
                self.lambda = edit_value;
                ls = findobj('Tag','lambda_slider');
                ls.Value = edit_value;
            end
        end
    end
    
        end
        %
        function CheckIfSelected(self,src,event)  %#ok<INUSD>
    
    okay_button = findobj('Tag','okay_button');
    
    protocol_chbs = findobj('Tag','protocols_chb');
    selected = 0;
    for pr = 1:length(protocol_chbs)
        if get(protocol_chbs(pr),'Value') == 1
            selected = selected + 1;
        end
    end
    
    if selected < 1
        set(okay_button,'enable','off');
    else
        set(okay_button,'enable','on');
    end
    
        end
        % тут рассчитываются пространственные фильтры для разных вариаций
        function CSPLearning(self,data_sets,data_names)
    %%data_sets_choices(n,2)
    choices = nchoosek(1:length(data_sets),2);
    
    for ch = 1:size(choices,1)
        if size(choices,1) == 1
            choice = choices;
        else
            choice = choices(ch,:);
        end
        
        %%run pairwise csp learning
        first_raw = data_sets{choice(1)};
        second_raw = data_sets{choice(2)};
        first_name = data_names(choice(1));
        second_name = data_names(choice(2));
        try
            
            %fetch the data of the choices
            
            if ~isempty(self.csp_settings.n_comp)
                Ncomp = self.csp_settings.n_comp;
            else
                Ncomp = 2;
            end
        catch
            Ncomp = 2;
        end
        try
            if ~isempty(self.csp_settings.init_band)
                init_band = self.csp_settings.init_band;
            else
                init_band = self.init_band;
            end
        catch
            init_band = self.init_band;
        end
        
        for ib = 1:4
            band = init_band +ib-1 ;
            %[z, p, k] = cheby1(3,1,band/(0.5*self.sampling_frequency),'bandpass');
            %[b,a] = zp2tf(z,p,k);
            %                     x = filtfilt(b,a,x_raw)';
            %                     C10 = x(:,1:fix(end/2))* x(:,1:fix(end/2))'/fix(size(x,2)/2);
            %                     C20 = x(:,fix(end/2)+1:end)* x(:,fix(end/2)+1:end)'/fix(size(x,2)/2);
            filt = CreateFilter(band,self.sampling_frequency);
            x1 = filtfilt(filt, first_raw)';
            x2 = filtfilt(filt, second_raw)';
            C10 = x1 * x1' / size(x1,2);
            C20 = x2 * x2' / size(x2,2);
            
            nchan = size(C10,1);
            
            %%regularize covariances
            Lambda = 0.1;%%%%%%%%%%%%%%%%%%%%%%
            C1 = C10 + Lambda * trace(C10) * eye(nchan) / nchan;
            C2 = C20 + Lambda * trace(C20) * eye(nchan) / nchan;
            %%do generalized eigenvalue decomp
            [V, d] = eig(C1,C2); %#ok<ASGLU>
            iV = inv(V);
            M12{ib} = V(:,[1:Ncomp, end-Ncomp+1:end])';
            G12{ib} = iV([1:Ncomp, end-Ncomp+1:end],:);
        end
        %%show the heads
        name = [first_name '-' second_name];
        hh1 = figure;
        title(name);
        
        StandChannels = load('StandardEEGChannelLocations.mat');
        chan_labels = self.used_ch(:,1)';
        Nbands = length(G12);
        PlotIndex = 1;
        selected = {};
        for ib = 1:Nbands
            rearranged_map = rearrange_channels(G12{ib}',chan_labels, StandChannels.channels);
            Nmaps = size(rearranged_map,2);
            for tpm=1:Nmaps
                sp(PlotIndex) = subplot(Nbands,Nmaps,PlotIndex);
                
                %                            topoplot(rearranged_map(:,tpm), StandChannels.channels, 'electrodes', 'labelpoint', 'chaninfo', StandChannels.chaninfo);
                topoplot(rearranged_map(:,tpm), StandChannels.channels,  'chaninfo', StandChannels.chaninfo);
                hold on;
                sibs = get(sp(PlotIndex),'Children');
                for k = 1:length(sibs)
                    set(sp(PlotIndex).Children(k), 'ButtonDownFcn', @(src,event)toggleplot(src,event));
                end
                title(num2str(PlotIndex));
                %add legend
                PlotIndex = PlotIndex+1;
            end;
        end
        okay_btn = uicontrol('Parent',hh1,'Style', 'pushbutton', 'String', 'OK', 'Callback', 'uiresume', 'Position', [230 10 100 35],'Tag','SelectHeadsBtn','enable','off');
        
        
        uiwait();
        
        MapIndex = cellfun(@str2num,selected);
        BandNumber = fix((MapIndex-1)/(2*Ncomp))+1;
        CompNumber = mod(MapIndex-1,(2*Ncomp))+1;
        close(hh1);
        w_ssd = zeros(length(MapIndex),length(M12{1}));
        for bn = 1:length(MapIndex)
            w_ssd(bn,:) = M12{BandNumber(bn)}(CompNumber(bn),:);
        end
        
        %%save as DS
    end
    
        end
        % создание нового производного сигнала из фиктивного
        function NewDS = CreateNewDS(self,signal_name,spatial_filter, band,filename)
    %%init dummy signal
    dummy_signal = struct();
    if nargin > 1
        dummy_signal.sSignalName = signal_name;
    else
        dummy_signal.sSignalName = '';
    end
    %%if raw signal exists, use its channels to copy to dummy ds
    if ~isempty(self.derived_signals)
        channels = cell(length(self.derived_signals{1}.channels),2);
        for ch = 1:length(channels)
            channels{ch,1} = self.derived_signals{1}.channels{ch};
            channels{ch,2} = 1;
        end
        %else use self.channel_labels and the weigth of one
    else
        channels = cell(size(self.channel_labels,2));
        for ch = 1:length(channels)
            channels{ch,1} = self.channel_labels{ch};
            channels{ch,2} = 1;
        end
    end
    dummy_signal.filters = cell(0,0);
    dummy_signal.channels = channels;
    
    %%DS to use
    NewDS= DerivedSignal(1,dummy_signal, self.sampling_frequency, self.exp_data_length ,self.channel_labels,self.plot_length);
    if strcmpi(dummy_signal.sSignalName,'raw')
        NewDS.ring_buff = circVBuf(self.plot_size,length(channels),0);
        NewDS.collect_buff = circVBuf(self.exp_data_length,length(channels),0);
    else
        NewDS.ring_buff = circVBuf(self.plot_size,1,0);
        NewDS.collect_buff = circVBuf(self.exp_data_length,1,0);
    end
    if nargin > 4
        NewDS.channels_file = filename;
    end
    if nargin > 3
        NewDS.UpdateTemporalFilter(size(spatial_filter,2),band);
    end
    if nargin > 2 && ~isempty(self.derived_signals)
        NewDS.UpdateSpatialFilter(spatial_filter,self.derived_signals{1},self.bad_channels);
    elseif nargin > 2
        NewDS.UpdateSpatialFilter(spatial_filter);
    end
    
    
        end
        % создает составной производный сигнал, используется в CreateCompositeDS
        function NewCDS = CreateNewCompositeDS(self,parent1,parent2,op,signal_name)
    NewCDS = DerivedSignal;
    NewCDS.signal_type = 'composite';
    if nargin > 4
        NewCDS.signal_name = signal_name;
    else
        NewCDS.signal_name = 'CompositeDS';
    end
    NewCDS.parents = {parent1, parent2};
    NewCDS.op = op;
    NewCDS.ring_buff = circVBuf(self.plot_size,1,0);
    NewCDS.collect_buff = circVBuf(self.exp_data_length,1,0);
    NewCDS.sampling_frequency = self.sampling_frequency;
    %recalc stats
    d1 = parent1.statvalues;
    d2 = parent2.statvalues;
    if isempty(d1) || isempty(d2)
        disp('To create a new derived signal gather some statistics')
        return
    else
        if length(d1) > length(d2)
            diff = length(d1) - length(d2);
            d1 = d1(diff+1:end);
        else
            diff = length(d2) - length(d1);
            d2 = d2(diff+1:end);
        end
        if strcmp(op,'+')
            values = abs(d1)+abs(d2);
        elseif strcmp(op,'-')
            values = abs(d1)-abs(d2);
        end
        NewCDS.statvalues = values;
        self.feedback_manager.average(end+1) = mean(values);
        self.feedback_manager.standard_deviation(end+1) = std(values);
    end
    %write to file
    
    
        end
        % возвращает структуру в которой хранятся данные о новом протоколе
        % используется в закоментированном коде 
        function NewRP = CreateNewRP(self,protocol_name,actual_size) %#ok<INUSL>
    NewRP = RealtimeProtocol;
    NewRP.protocol_name = protocol_name;
    NewRP.to_update_statistics = true;
    NewRP.actual_protocol_size = actual_size;
    
        end
        
        function [results,data_names,averages,stddevs,dss] = Recalculate(self,data_sets,window,av,stddev)
    % >> self = EEGLSL;
    % >> Recalculate(self, 1:10, 10)
    %
    %ans =
    %
    %    5.5000    5.5000    5.5000    5.5000    5.5000    5.5000    5.5000    5.5000    5.5000    5.5000
    %
    % >> Recalculate(self,1:10,2)
    %
    %ans =
    %
    %     1.5000    1.5000    3.5000    3.5000    5.5000    5.5000    7.5000    7.5000    9.5000    9.5000
    %
    % >> sum(Recalculate(self,1:10,10)) == sum(Recalculate(self,1:10,2))
    %
    %ans =
    %
    % 1
    %
    % >> sum(Recalculate(self,1:100,10))
    %
    %ans =
    %
    % 5050
    %
    if nargin < 2 && length(self.derived_signals) > 1
        %open the window
        %select protocol(s)
        ss = get(groot,'ScreenSize');
        f = figure('Tag', 'recalculate_protocol_choice','Position',[0.3*ss(3), 0.15*ss(4)/2,ss(3)*0.4,ss(4)*0.8]);
        protocols_to_use = uicontrol('Parent', f,'Style', 'text', 'Position',[f.Position(3)*0.12,f.Position(4)*0.89, f.Position(3)*0.2, f.Position(4)*0.1],'Tag','protocols_to_select','String','Data to calculate','FontSize',11,'HorizontalAlignment','center');
        max_height = f.Position(4) - f.Position(4)*0.05;
        if self.next_protocol > length(self.feedback_protocols)
            finish = length(self.feedback_protocols);
        else
            finish = self.next_protocol-1;
        end
        for pr = 1:finish
            
            bgr = 0.94-[0.1 0.1 0.1] * mod(pr-1,2);
            protocol_chb{pr} = uicontrol('Parent',f,'Style','checkbox','Position',[f.Position(3)*0.1,max_height-f.Position(4)*0.03*pr, f.Position(3)*0.3, f.Position(4)*0.02],'Tag','protocols_chb','BackgroundColor',bgr,'Callback',@self.CheckIfSelected,'String',self.feedback_protocols{pr}.show_as);
            
            %protocol_count{p} = uicontrol('Parent',csp_figure,'Style','text','Position', [csp_figure.Position(3)*0.03,max_height-csp_figure.Position(4)*0.05*pr, csp_figure.Position(3)*0.05, csp_figure.Position(4)*0.04],'String', num2str(pr),'HorizontalAlignment','left','Tag','Protocol count','BackgroundColor',bgr); %#ok<NASGU>
            %protocol_name{pr} = uicontrol('Parent',csp_figure,'Style','text','Position', [csp_figure.Position(3)*0.07,max_height-csp_figure.Position(4)*0.05*pr, csp_figure.Position(3)*0.25, csp_figure.Position(4)*0.04],'String', self.feedback_protocols{pr}.protocol_name,'HorizontalAlignment','left','Tag','Protocol name text','BackgroundColor',bgr); %#ok<NASGU>
            %edit_name{pr} = uicontrol('Parent',csp_figure,'Style','edit','Position', [csp_figure.Position(3)*0.45,max_height-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'String', self.feedback_protocols{pr}.protocol_name,'HorizontalAlignment','left','Tag','Edit name text','BackgroundColor',bgr);
            
        end
        ds_to_use = uicontrol('Parent', f,'Style', 'text', 'Position',[f.Position(3)*0.52,f.Position(4)*0.89, f.Position(3)*0.4, f.Position(4)*0.1],...
            'Tag','signals_to_select','String','Signals to show','FontSize',11,'HorizontalAlignment','center');
        for ds = 2:length(self.derived_signals)
            
            bgr = 0.94-[0.1 0.1 0.1] * mod(ds-1,2);
            ds_chb{ds} = uicontrol('Parent',f,'Style','checkbox','Position',[f.Position(3)*0.5,max_height-f.Position(4)*0.03*ds, f.Position(3)*0.45, f.Position(4)*0.02],'Tag','ds_chb','BackgroundColor',bgr,'Callback',@self.CheckIfSelected,'String',self.derived_signals{ds}.signal_name,'Value',1);
            
            %protocol_count{p} = uicontrol('Parent',csp_figure,'Style','text','Position', [csp_figure.Position(3)*0.03,max_height-csp_figure.Position(4)*0.05*pr, csp_figure.Position(3)*0.05, csp_figure.Position(4)*0.04],'String', num2str(pr),'HorizontalAlignment','left','Tag','Protocol count','BackgroundColor',bgr); %#ok<NASGU>
            %protocol_name{pr} = uicontrol('Parent',csp_figure,'Style','text','Position', [csp_figure.Position(3)*0.07,max_height-csp_figure.Position(4)*0.05*pr, csp_figure.Position(3)*0.25, csp_figure.Position(4)*0.04],'String', self.feedback_protocols{pr}.protocol_name,'HorizontalAlignment','left','Tag','Protocol name text','BackgroundColor',bgr); %#ok<NASGU>
            %edit_name{pr} = uicontrol('Parent',csp_figure,'Style','edit','Position', [csp_figure.Position(3)*0.45,max_height-csp_figure.Position(4)*0.09*pr, csp_figure.Position(3)*0.3, csp_figure.Position(4)*0.05],'String', self.feedback_protocols{pr}.protocol_name,'HorizontalAlignment','left','Tag','Edit name text','BackgroundColor',bgr);
            
        end
        okay_button = uicontrol('Parent',f,'Style','pushbutton','Position', [f.Position(3)*0.75,f.Position(4)*0.05, f.Position(3)*0.09,f.Position(4)*0.12],'String', 'OK','Tag','okay_button','Callback','uiresume','enable','off');
        uiwait();
        
        data_sets = {};
        data_names = {};
        window_sizes = {};
        averages = [];
        stddevs = [];
        used_pr = 0;
        dss = [];
        
        for ds = 2:length(self.derived_signals)
            if get(ds_chb{ds},'Value')
                dss(end+1) = ds;
            end
        end
        
        for pr = 1:finish
            if get(protocol_chb{pr},'Value')
                used_pr = used_pr + 1;
                idx1 = self.protocol_indices(pr,2)-self.protocol_indices(self.ssd+1,2);
                idx2 = self.protocol_indices(pr+1,2)-self.protocol_indices(self.ssd+1,2);
                %check data length
                %test whether idx are correct
                if idx1 > self.derived_signals{2}.collect_buff.lst ||idx2 > self.derived_signals{2}.collect_buff.lst
                    disp(['Wrong data indices, protocol ' num2str(pr) ' ' self.feedback_protocols{pr}.show_as])
                else
                    
                    %grab the data
                    
                    for r = 1:length(dss)
                        data_sets{used_pr, r} = self.derived_signals{dss(r)}.collect_buff.raw(self.derived_signals{dss(r)}.collect_buff.fst+idx1:self.derived_signals{dss(r)}.collect_buff.fst+idx2-1,:);
                        
                    end
                    data_names{end+1} = self.feedback_protocols{pr}.show_as;
                    if ~isempty(self.feedback_protocols{pr}.window_size)
                        
                        window_sizes{end+1} = round(self.feedback_protocols{pr}.window_size);
                    else
                        if isempty(window_sizes)
                            window_sizes{end+1} = 20;
                        else
                            window_sizes{end+1} = window_sizes{end};
                        end
                    end
                end
            end
        end
        close(f);
        
        
        
    elseif nargin < 2 && length(self.derived_signals) < 2
        disp('Nothing to recalculate!')
        return
    end
    
    if iscell(data_sets)
        results = cell(size(data_sets));
        for p = 1:size(data_sets,1)
            window = window_sizes{p};
            for r = 1:size(data_sets,2)
                res = zeros(length(data_sets{p,r}),1);
                if ~isempty(self.derived_signals{dss(r)}.statvalues)
                    av = mean(abs(self.derived_signals{dss(r)}.statvalues));%self.feedback_manager.average(ds);
                    s = std(abs(self.derived_signals{dss(r)}.statvalues));%self.feedback_manager.standard_deviation(ds);
                else
                    av = self.derived_signals{dss(r)}.file_av;
                    s = self.derived_signals{dss(r)}.file_std;
                end
                for i = window:window:length(data_sets{p,r})-window
                    dat = data_sets{p,r}(i-window+1:i);
                    val = sum(abs(dat))/window;
                    try
                        res(i-window+1:i) = (val-av)/s;
                    catch
                        (val-av)/s %#ok<NOPRT>
                    end
                    
                end
                results{p,r} = res;
                averages(p,r) = mean(res);
                stddevs(p,r) = std(res);
            end
            
        end
        
    elseif isnumeric(data_sets)
        if nargin < 3 || isempty(window)
            window = self.current_window_size;
        end
        if nargin < 4
            av = 0;
        end
        if nargin < 5
            stddev = 1;
        end
        results = zeros(size(data_sets));
        for i = window:1:length(data_sets)
            dat = data_sets(i-window+1:i);
            val = mean(abs(dat));
            results(i-window+1:i) = (val-av)/stddev;
        end
        if nargout > 1
            data_names = {};
            averages = mean(results);
            stddevs = std(results);
            
        end
        %takes ds_data, window_size, and recalculates feedback using
        %the same algorithm as in RefreshFb function
    end
        end
        % используется в StopRecording
        function PlotFB(self)
    [results,protocol_names,averages,deviations,dss] = self.Recalculate;
    plot_size = length(protocol_names);
    for pr = 1:size(results,1)
        f_pr(pr) = figure;
        legend_str = {};
        for r = 1:size(results,2)
            plot( 1:length(results{pr,r}), results{pr,r});
            hold on;
            legend_str{end+1} = self.derived_signals{dss(r)}.signal_name;
        end
        title(protocol_names{pr});
        legend(legend_str);
    end
    
    
    legend_str = {};
    
    f = figure;
    for r = 1:length(results)
        e = errorbar(averages(:,r), deviations(:,r));
        hold on;
        legend_str{end+1} = self.derived_signals{dss(r)}.signal_name;
    end
    set(gca,'XTick',1:plot_size);
    set(gca,'XTickLabel',protocol_names);
    xlabel('Protocols');
    ylabel('Normalized values of calculated feedback (Mean +/- std)');
    legend(legend_str);
        end
        % передает данные по блютусу на робота используется в констркуторе 
        function TransmitToBluetooth(self,timerobj,event) %#ok<INUSD>
    
    
    s = 0;
    if self.bt_connected
        bt = get(self.bluetooth_connection);
        s = ~strcmp(bt.Status,'closed');
    end
    if s
        l = self.signals_to_bt(1);
            r = self.signals_to_bt(2);
        
            
            if l > 1 
                f1 = self.feedback_manager.feedback_vector(l-1);
                if f1 > 0 && f1 < 1.5
                ch1 = 0.4;%f1;%self.feedback_manager.feedback_vector(l-1);
                else
                    ch1 = 0;
                end
            else
                ch1 = 0;
            end
            
            if r > 1 
                f2 = self.feedback_manager.feedback_vector(r-1);
                if f2 > 0 && f2< 1.5
                    ch2 = 0.4;%f2;
                else
                    ch2 = 0;
                end
            else
                ch2 = 0;
            end
        if self.feedback_type == 1
            f1 = self.feedback_manager.feedback_vector(l-1);
            f2 = self.feedback_manager.feedback_vector(r-1);
            if f1 > 0 && f1 < 1.5
                ch1 = 0.2;
            else 
                ch1 = 0;
            end
            if f2 > 0 && f2 < 1.5
                ch2 = 0.2;
            else
                ch2 = 0;
            end
%             if f1 < 0
%                 ch1 = 0.5;%-f1;
%             else
%                 ch1 = 0;
%             end
%             if f2 < 0
%                 ch2 = 0.5;%-f2;
%             else
%                 ch2 = 0;
%             end
%             if f1 < f2 && f1 < -0.5
%                 ch1 = -f1;
%                 ch2 = 0;
%             elseif f2 < f1 && f2 < -0.5
%                 ch1 = 0;
%                 ch2 = -f2;
%             else  
%                 ch1 = 0;
%                 ch2 = 0;
%             end
%             if self.feedback_manager.feedback_vector > 0%self.feedback_manager.average% + self.feedback_manager.standard_deviation%*self.lda_threshold
%                 %ch1 = self.feedback_manager.feedback_vector;
%                 ch1 = 1;
%                 ch2 = 0;
%             elseif self.feedback_manager.feedback_vector < 0%self.feedback_manager.average% - self.feedback_manager.standard_deviation%*self.lda_threshold
%                 ch1 = 0;
%                 ch2 = 1;
%                 %ch2 = abs(self.feedback_manager.feedback_vector);
%             else 
%                 ch1 = 0;
%                 ch2 = 0;
%             end
        end
        out1 = uint8((ch1+4)*32);
        out2 = uint8((ch2+4)*32);
        bytes = uint8([6 0 128 9 0 2 out1 out2]);
        try
            fwrite(self.bluetooth_connection,bytes);
        catch
            'BT connection DNE' %#ok<NOPRT>
        end
        
        
    end
    
        end
        % используется в function PlotEEGData
        function CreateCompositeDS(self,obj,event) %#ok<INUSD>
    
            
            finished = 0;
            ds_string = {};
            if length(self.derived_signals) >= 2
                for ds = 2:length(self.derived_signals) %except for raw
                    %if ~strcmpi(self.derived_signals{ds}.signal_type,'composite') %and composites
                    ds_string{end+1} = [num2str(ds) ' ' self.derived_signals{ds}.signal_name];
                    %end
                end
                
                ops = {'+','-'};
                while ~finished
                    comp_string = {};
                    for ds = 2:length(self.derived_signals)
                        if strcmpi(self.derived_signals{ds}.signal_type,'composite')
                            comp_string{end+1} = [num2str(ds) ' ' self.derived_signals{ds}.signal_name];
                            comp_string{end+1} = '';
                        end
                    end
                    %%%show window of choosing ds and creating a new one
                    f = figure('Tag','create composite ds');
                    p = f.Position;
                    t = uicontrol(f, 'Style','text', 'String','Choose parents for composite signal. OK to add a signal, Cancel to finish','Position',[p(3)*0.05,p(4)*0.8, p(3)*0.3,p(4)*0.1] );
                    ok = uicontrol(f,'Style','pushbutton','String','Ok','Callback','uiresume','Position',[p(3)*0.4,p(4)*0.05, p(3)*0.1,p(4)*0.05]);
                    cancel = uicontrol(f,'Style','pushbutton','String','Cancel','Callback',@self.DoNothing,'Position',[p(3)*0.55,p(4)*0.05, p(3)*0.1,p(4)*0.05],'Tag','cancel_button');
                    parent1 = uicontrol(f,'Style','popupmenu','String',ds_string,'Position',[p(3)*0.05,p(4)*0.6, p(3)*0.2,p(4)*0.05]);
                    op = uicontrol(f,'Style','popupmenu','String',ops,'Position',[p(3)*0.26,p(4)*0.6, p(3)*0.06,p(4)*0.05]);
                    parent2 = uicontrol(f,'Style','popupmenu','String',ds_string,'Position',[p(3)*0.33,p(4)*0.6, p(3)*0.2,p(4)*0.05]);
                    comp_txt = uicontrol(f,'Style','text','String',comp_string,'Position',[p(3)*0.5,p(4)*0.65, p(3)*0.4,p(4)*0.3]);
                    
                    
                    uiwait();
                    if ~ishandle(f)
                        break;
                    end
                    p1 = strsplit(parent1.String{parent1.Value});
                    p2 = strsplit(parent2.String{parent2.Value});
                    parent1_idx = str2num(p1{1}); %#ok<ST2NM>
                    parent2_idx = str2num(p2{1}); %#ok<ST2NM>
                    ds_parent1 = self.derived_signals{parent1_idx};
                    ds_parent2 = self.derived_signals{parent2_idx};
                    operator = op.String{op.Value};
                    switch operator
                        case '+'
                            name = [self.derived_signals{parent1_idx}.signal_name ' + ' self.derived_signals{parent2_idx}.signal_name];
                        case '-'
                            name = [self.derived_signals{parent1_idx}.signal_name ' - ' self.derived_signals{parent2_idx}.signal_name];
                    end
                    if isempty(ds_parent1.statvalues) || isempty(ds_parent2.statvalues)
                        disp('To create a new derived signal gather some statistics')
                        delete(f)
                        return;
                    else
                        self.derived_signals{end+1} = self.CreateNewCompositeDS(ds_parent1, ds_parent2, operator,name);
                    end
                    
                    %reset the interface
                    self.ds_ylabels_fixed = 0;
                    self.ds_dropmenu_set = 0;
                    delete(f)
                    
                end
            end
        end
        % используется в function ConnectToBluetooth и в function SetTwoBars
        function [signal1, signal2] = SelectSignals(self,obj,event) %#ok<INUSD>
    
    ds_string = {'-'};
    if length(self.derived_signals) > 1
        for ds = 2:length(self.derived_signals) %except for raw
            ds_string{end+1} = [num2str(ds) ' ' self.derived_signals{ds}.signal_name];
            
        end
    end
    f = figure('Tag','choose signals for bt');
    p = f.Position;
    t = uicontrol(f, 'Style','text', 'String','Choose signals to transmit.','Position',[p(3)*0.05,p(4)*0.8, p(3)*0.3,p(4)*0.1] );
    ok = uicontrol(f,'Style','pushbutton','String','Ok','Callback','uiresume','Position',[p(3)*0.4,p(4)*0.05, p(3)*0.1,p(4)*0.05]);
    cancel = uicontrol(f,'Style','pushbutton','String','Cancel','Callback',@self.DoNothing,'Position',[p(3)*0.55,p(4)*0.05, p(3)*0.1,p(4)*0.05],'Tag','cancel_button');
    l_text = uicontrol(f,'Style','text','String','Left', 'Position', [p(3)*0.05,p(4)*0.7, p(3)*0.2,p(4)*0.05]);
    r_text = uicontrol(f,'Style','text','String','Right', 'Position', [p(3)*0.33,p(4)*0.7, p(3)*0.2,p(4)*0.05]);
    left = uicontrol(f,'Style','popupmenu','String',ds_string,'Position',[p(3)*0.05,p(4)*0.6, p(3)*0.2,p(4)*0.05]);
    right = uicontrol(f,'Style','popupmenu','String',ds_string,'Position',[p(3)*0.33,p(4)*0.6, p(3)*0.2,p(4)*0.05]);
    if self.signals_to_bt(1)
        left.Value = self.signals_to_bt(1);
    end
    if self.signals_to_bt(2)
        right.Value = self.signals_to_bt(2);
    end
    uiwait();
    if ishandle(f)
        if ~strcmp(left.String{left.Value},'-')
            l = strsplit(left.String{left.Value});
            signal1 = str2double(l{1});
        else
            signal1 = 0;
        end
        if ~strcmp(right.String{right.Value},'-')
            r = strsplit(right.String{right.Value});
            signal2 = str2double(r{1});
        else
            signal2 = 0;
        end
        close(f);
        
    else
        signal1 =  self.signals_to_bt(1);
        signal2 = self.signals_to_bt(2);
    end
    
        end
        % хорошее соединение по блютусу с роботом используется в function PlotEEGData
        function ConnectToBluetooth(self,obj,event) %#ok<INUSD>
    if self.bt_connected %disconnect
        stop(self.timer_bt);
        btc = findobj('Tag','connect_to_bt_button');
        btc.Enable = 'on';
        fclose(self.bluetooth_connection);
        self.bt_connected = 0;
        btc.String = 'Connect to Bluetooth';
        
    else %connect
        %             ds_string = {'-'};
        %             if length(self.derived_signals) > 1
        %                 for ds = 2:length(self.derived_signals) %except for raw
        %                     ds_string{end+1} = [num2str(ds) ' ' self.derived_signals{ds}.signal_name];
        %
        %                 end
        %             end
        
        [self.signals_to_bt(1), self.signals_to_bt(2)] = self.SelectSignals(0,0);
        btc = findobj('Tag','connect_to_bt_button');
        %         if ~self.bt_connected
        try
            btc.String = 'Connecting...';
            btc.Enable = 'off';
            self.bluetooth_connection  = Bluetooth('Nerv',1);
            try
                fopen(self.bluetooth_connection);
                btc.Enable = 'on';
                btc.String = 'Disconnect from Bluetooth';
                self.bt_connected = 1;
            catch err
                if strcmp(err.identifier,'instrument:fopen:opfailed')
                    btc.String = 'Connect to Bluetooth';
                    btc.Enable = 'on';
                    disp('Bluetooth connection failed');
                end
            end
            self.bt_refresh_rate = 0.05;
        catch err
            
            err.identifier
        end
%         else
%             fclose(self.bluetooth_connection);
%             self.bt_connected = 0;
%             btc.String = 'Connect to Bluetooth';
%         end
    end
    if strcmpi(self.timer_bt.Running,'off')
        start(self.timer_bt);
    end
        end
        % используется в Receive и в StartRecording 
        function SetFBWindow(self)
    if self.current_protocol && self.current_protocol <= length(self.feedback_protocols)
        %set fb type
        if isprop(self.feedback_protocols{self.current_protocol},'fb_type') && ~isempty(self.feedback_protocols{self.current_protocol}.fb_type)
            try
                self.fb_type = self.feedback_protocols{self.current_protocol}.fb_type;
            catch
                'Error while getting fb_type, function Receive, 533' %#ok<NOPRT>
            end
        elseif ~isempty(strfind(lower(self.feedback_protocols{self.current_protocol}.protocol_name), 'feedback'))
            self.fb_type = self.feedback_protocols{self.current_protocol}.protocol_name;
        end
        if isempty(self.feedback_protocols{self.current_protocol}.string_to_show)
            
             if self.show_fb_count
                set(self.fb_count,'Visible','on');
             end
            
            if strfind(lower(self.fb_type),'color')
                xlim(self.feedback_axis_handle, [0.5 1]);
                ylim(self.feedback_axis_handle,[0.5 1]);
                set(self.fb_stub, 'Visible', 'off');
                set(self.fbplot_handle,'Visible', 'off');
                set( self.feedback_axis_handle,'Visible','off');
                set(self.fb_stub,'Visible', 'off')
                if self.feedback_protocols{self.current_protocol}.show_counter
                    set(self.fb_count,'Visible','on');
                end
                if self.show_fb_rect
                    self.common_feedback_rectangle.Visible = 'on';
                end
                
            elseif strfind(lower(self.fb_type),'mock')
                xlim(self.feedback_axis_handle, [0.5 1]);
                ylim(self.feedback_axis_handle,[0.5 1]);
                set(self.fb_stub, 'Visible', 'off');
                set(self.fbplot_handle,'Visible','off');
                set(self.fb_stub,'Visible', 'off')
                if self.show_fb_count
                    set(self.fb_count,'Visible','on');
                end
                if self.show_fb_rect
                    set(self.common_feedback_rectangle,'Visible','on');
                end
            elseif strfind(lower(self.fb_type),'mixed')
                set(self.fb_stub, 'Visible', 'off');
                set(self.fbplot_handle,'Visible','off');
                xlim(self.feedback_axis_handle, [-1 3]);
                ylim(self.feedback_axis_handle,[-1.5 7.5]);
                set(self.fb_count,'Visible','off');
            elseif strfind(lower(self.fb_type),'bar')
                
                self.fig_feedback.Color = [0.94 0.94 0.94];
                set(self.fbplot_handle,'Visible','on'); %feedback if bar
                set(self.fbplot_handle,'FaceColor',[1 0 0]);
                set(self.fbplot_handle,'EdgeColor',[0 0 0]);
                xlim(self.feedback_axis_handle, [1 3]);
                ylim(self.feedback_axis_handle,[-1.5 7.5]);
                set(self.fb_count,'Visible','off');
            elseif strcmpi(self.feedback_protocols{self.current_protocol}.protocol_name,'rest')
                set(self.fig_feedback,'Color',[0.94 0.94 0.94]);
                set(self.fb_stub, 'Visible', 'off'); %string
                set(self.fbplot_handle,'Visible','off');
                set(self.feedback_axis_handle,'Visible','off');
                set(self.fb_count,'Visible','off');
                set(self.common_feedback_rectangle,'Visible','off');
                
            end
        else
            self.fb_stub.String = self.feedback_protocols{self.current_protocol}.string_to_show;
            set(self.fb_count,'Visible','off');
            set(self.common_feedback_rectangle,'Visible','off');
            set(self.fig_feedback,'Color',[0.94 0.94 0.94]);
            set(self.fbplot_handle,'Visible','off');
            set(self.fb_stub,'Visible', 'on'); %string
            set(self.fbplot_handle,'FaceColor',[1 1 1]);
            set(self.fbplot_handle,'EdgeColor','none');
            set(self.fb_count,'Visible','off');
            
        end
        
        
        
        
    elseif ~self.current_protocol
        set(self.fb_count,'Visible','off');
        set(self.common_feedback_rectangle,'Visible','off');
        set(self.fb_stub,'Visible', 'off')
        
        if self.fb_statistics_set %after update_stats
            set(self.fb_stub, 'Visible', 'off');
            if strfind(lower(self.fb_type),'bar')
                
                self.fig_feedback.Color = [0.94 0.94 0.94];
                set(self.fbplot_handle,'Visible','on'); %feedback if bar
                set(self.fbplot_handle,'FaceColor',[1 0 0]);
                set(self.fbplot_handle,'EdgeColor',[0 0 0]);
                xlim(self.feedback_axis_handle, [1 3]);
                ylim(self.feedback_axis_handle,[-1.5 7.5]);
                
            elseif strfind(lower(self.fb_type),'color')
                
                set( self.feedback_axis_handle,'Visible','off');
                set(self.fbplot_handle,'Visible','off');
            elseif strfind(lower(self.fb_type),'mock')
                xlim(self.feedback_axis_handle, [0.5 1]);
                ylim(self.feedback_axis_handle,[0.5 1]);
                set(self.fb_stub, 'Visible', 'off');
                set(self.fbplot_handle,'Visible','off');
            elseif strfind(lower(self.fb_type),'mixed')
                set(self.fb_stub, 'Visible', 'off');
                set(self.fbplot_handle,'Visible','off');
                xlim(self.feedback_axis_handle, [-1 3]);
                ylim(self.feedback_axis_handle,[-1.5 7.5]);
            else %zero protocol after update stats
                set(self.fig_feedback,'Color',[0.94 0.94 0.94]);
                set(self.fb_stub, 'Visible', 'off'); %string
                set(self.fbplot_handle,'Visible','off'); %fb if bar
            end
        end
        
    end
        end
        % используется в закоментированном коде в конструкторе
        function TestTiming(self,~,~)
    [sample, ~] = self.inlet.pull_chunk();
    window_size  = 50;
    tic
    self.nd = [self.nd sample];
    if size(self.nd,2) >= window_size
        dat = self.nd(3:3,1:window_size);
        self.nd = self.nd(:,window_size + 1:end);
        fbs = max(abs(dat));
        try
            set(self.fig_feedback,'Color',[20*fbs 20*fbs 20*fbs]); %20 hz
        catch
            fbs %#ok<NOPRT>
        end
        
    end
    self.plot_timing(end+1) = toc;
        end
        % останавливает таймеры и удаляет объект
        function delete(self)
    if exist('self.timer_new_data','var')
        stop(self.timer_new_data);
    end
    if exist('self.timer_disp','var')
        stop(self.timer_disp);
    end
    if exist('self.timer_fb','var')
        stop(self.timer_fb);
    end
    clear  self
        end
        % обратная связь в lsl - поток? используется в RefreshFB
        function FbToLSL(self)
            if isempty(self.fb_lsl_output)
                sf = 1/self.fb_refresh_rate;
                lsllib = lsl_loadlib();
                eeg_info = lsl_streaminfo(lsllib,'feedback', 'feedback',1, sf,'cf_int16','neurofeedback');
                self.fb_lsl_output = lsl_outlet(eeg_info);
            end
            
            if ~isempty(self.feedback_manager.feedback_vector)
                if self.feedback_manager.feedback_vector(self.signal_to_feedback-1) > self.y_limit(2)
                    feedback = 255;
                elseif self.feedback_manager.feedback_vector(self.signal_to_feedback-1) < self.y_limit(1)
                    feedback = 0;
                else
                    feedback = 255*(1/self.fb_sigmas+1/self.fb_sigmas*self.feedback_manager.feedback_vector(self.signal_to_feedback-1));
                end
                
                self.fb_lsl_output.push_sample(feedback);
            end
            
        end
        % используется в PlotEEGData
        function HandleKBDInput(self,obj,event)  %#ok<INUSL>
            disp(event.Key)
            return
            %the callback is not called when the object (slider) is still in focus
            if obj == self.raw_and_ds_figure %#ok<UNRCH>
                
                raw_scale = self.raw_scale_slider.Value;
                if ishandle(self.ds_scale_slider)
                    ds_scale = self.ds_scale_slider.Value;
                else
                    ds_scale = 0;
                end
                if strcmp(event.Key,'uparrow')
                    if self.raw_scale_slider.Value < self.raw_scale_slider.Max
                        raw_scale = raw_scale +1;
                    end
                    if ishandle(self.ds_scale_slider) && self.ds_scale_slider.Value < self.ds_scale_slider.Max
                        ds_scale = ds_scale +1;
                    end
                elseif strcmp(event.Key,'downarrow')
                    if self.raw_scale_slider.Value > self.raw_scale_slider.Min
                        raw_scale = raw_scale -1;
                    end
                    if ishandle(self.ds_scale_slider) && self.ds_scale_slider.Value > self.ds_scale_slider.Min
                        ds_scale = ds_scale -1;
                    end
                end
                self.SetYScale('KBD',[raw_scale,ds_scale])
            end
        end
        % не используется
        function HandleMouseClick(self,obj,event) %#ok<INUSD>
            if strcmp(obj.Tag,'continue field')
                
                self.current_protocol = self.next_protocol;
                self.next_protocol = self.next_protocol + 1;
            end
        end
        % не используется
        function fb = FeedbackBasedOnSignal(self,vals) %#ok<INUSL>
            fb = abs(vals);
        end
    
end
end


function channels = read_montage_file(fname) %#ok<DEFNU>
montage = xml2struct(fname);
channels = {};
for i = 1:length(montage.neorec.transmission.clogicals.clogical)
    channels{end+1} = montage.neorec.transmission.clogicals.clogical{i}.name.Text;
end
end
function channels = get_channel_labels(input) %#ok<DEFNU> %input = inlet obj
ChS = input.info.desc.child('channels');
ch = ChS.first_child;
channels = {};
try
    
    while ch.PtrHandle
        l = ch.child('label');
        channels{end+1} = l.child_value ;
        ch = ch.next_sibling;
    end
catch
    channels = cell(1,input.channel_count());
    for i = 1:input.channel_count()
        channels{i} = num2str(i);
    end
end
ChS =  input.info.desc.child('channels');
ch = ChS.first_child;
channels = {};
try
    
    % while ch.next_sibling.PtrHandle
    while ch.PtrHandle
        l = ch.child('label');
        channels{end+1} = l.child_value ;
        ch = ch.next_sibling;
    end
catch
    channels = cell(1,input.channel_count());
    for i = 1:input.channel_count()
        channels{i} = num2str(i);
    end
end
end
function channels = read_channel_file(fname)%input = txt file

if nargin<1
    fname = 'channels.txt';
end
t = fileread(fname);
ch = strsplit(t, '\n');
if strcmp(ch(end), '')
    
    ch(end) = [];
end
channel_count = str2double(ch{1});
channels = {};
for c = 2:length(ch)
    channels{end+1} = ch{c};
end
channels = strtrim(channels);
if length(channels) ~= channel_count
    disp('Wrong number of channels')
else
    disp('Channels read successfully')
end

end
