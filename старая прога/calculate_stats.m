

function calculate_stats

%select statistic file
%
[fname, pathname, index] = uigetfile('Update_Stats.txt','Select txt file with statistics'); %#ok<ASGLU>
%
fname = strcat(pathname,fname);
%fname = 'D:\neurofeedback\results\Null\2015-08-21\11-43-44\Update_Stats.txt';
f = fopen(fname);
t = fscanf(f,'%c');
ls = strsplit(t,'\n');
%grab the info about ds
derived_signals = {};
columns = strsplit(ls{1},', ');
for col = 4:length(columns)
    if regexpi(columns{col},' av$')
        
        derived_signals{end + 1} = regexprep(columns{col},' av$','');
    elseif regexpi(columns{col},' std$')
        derived_signals{end + 1} = regexprep(columns{col},' std$','');
    end
end
%let user select DSs
[derived_signals, ia, ic] = unique(derived_signals,'stable'); %#ok<ASGLU>
[selected_ds,ok] = listdlg('ListString',derived_signals,'Name','Select DS to calculate');
if ~ok
    return
end
derived_signals = derived_signals(selected_ds);
% grab the info about protocols
protocols = {};
protocols_names = {};
for l = 2:length(ls)
    protocols{l-1} = strsplit(ls{l});
    try %#ok<TRYNC>
        protocols_names{l-1} = protocols{l-1}{3};
    end
end
av = zeros(length(derived_signals),1);
stddev = zeros(length(derived_signals),1);
% select needed protocol
[baseline_protocol,ok] = listdlg('ListString',protocols_names,'SelectionMode','single','Name','Select baseline protocol');
for ds = 1:length(derived_signals)
    for col = 2:length(columns)
        line = strsplit(ls{baseline_protocol+1});
        if strcmp(columns(col),[derived_signals{ds},' av'])
            av(ds) = str2double(line{col});
        elseif strcmp(columns(col),[derived_signals{ds},' std'])
            stddev(ds) = str2double(line{col});
        end    
    end
end


if ~ok
    return
end

%select other files
[data_files, pathname, index] = uigetfile('*.bin','Select data files','Multiselect','on'); %#ok<ASGLU>
%pathname = 'D:\neurofeedback\results\Null\2015-08-18\15-10-54\';
% data_files = {'1 Baseline Baseline 2.bin',...
%     '2 Feedback_color Feedback_color 2.bin',...
%     '3 Mock_feedback Mock_feedback 2.bin',...
%     '4 Rest Rest 2.bin'};
    
    
%read the header file to obtain ds indices
header_filename = strcat(pathname,'exp_info.hdr');
hf = fopen(header_filename);
ht = fscanf(hf,'%c');
headers = strsplit(ht,',');
indices = zeros(1,length(derived_signals));

for ds = 1:length(derived_signals)
    if isempty(find(not(cellfun('isempty',strfind(headers,derived_signals{ds}))))) %#ok<EFIND>
        disp(['the data files do not contain records of ' derived_signals{ds}]);
    else
        indices(ds) = find(not(cellfun('isempty',strfind(headers,derived_signals{ds}))));
    end
end
window_index = 0;
for i = 1:length(headers)
    if strcmpi(headers{i},'Window size')
        window_index = i;
    end
end



if isempty(nonzeros(indices))
    return
end
%get ds column(s) and window size for protocol

[~, selected_protocols,~,~,~] = GetDataProperties(pathname,data_files);
windows = cell(length(selected_protocols),1);
datasets = cell(length(selected_protocols),1);
feedbacks = cell(length(selected_protocols),length(derived_signals));
averages = zeros(length(selected_protocols),length(derived_signals));
stddevs = zeros(length(selected_protocols),length(derived_signals));
if ~window_index
    for pr = 1:length(data_files)
        wi = inputdlg(['Enter the window size (in samples) for protocol ' selected_protocols{pr}]);
        windows{pr} = str2double(wi); 
    end
end
%and calculate them
for df = 1:length(data_files)
    
    
    datasets{df} = ReadEEGData(strcat(pathname,data_files{df}));
    if size(datasets{df},2) < min(indices)
        averages(df,ds) = NaN;
        stddevs(df,ds) = NaN;
    else
        windows{df} = datasets{df}(1,window_index);
        datasets{df} = datasets{df}(:,indices);
        %select ds data
        for ds = 1:length(derived_signals)
            %find av and stddev
            [feedbacks{df}{ds},averages(df,ds),stddevs(df,ds)] = recalc(datasets{df}(:,ds),windows{df},av(ds),stddev(ds));

        end
        
    end
end

%aaaaaaand plot
figure;
legend_str = {};
for ds = 1:length(derived_signals)
    e = errorbar(averages(:,ds), stddevs(:,ds)); %#ok<NASGU>
    hold on;
    legend_str{end+1} = derived_signals{ds};
end
set(gca,'XTick',1:length(selected_protocols));
set(gca,'XTickLabel',selected_protocols);
xlabel('Protocols');
ylabel('Normalized values of calculated feedback (Mean +/- std)');
legend(legend_str);



%when calculating DSs, write down stats for it (and windows)

function [results,average,deviation] = recalc(data_set,window,av,stddev)

results = zeros(size(data_set));
for i = window:window:length(data_set)
    dat = data_set(i-window+1:i);
    val = sum(abs(dat))/window;
    results(i-window+1:i) = (val-av)/stddev;
end
average = mean(results);
deviation = std(results);
                    


% %global constants
% ELECTRODES = { 'Nz'    'LPA'    'RPA'    'PPO9h'    'PO7'    'PO9'    'POO9h'   'O1'    'I1'    'OI1h'    'Oz'    'Iz'    'OI2h'    'O2'    'I2'  'POO10h'    'PO8'    'PO10'    'PPO10h'    'PPO7h'    'PO5h'    'PPO3h'    'POO5'    'PO3h'    'PPO1h'    'POO3'    'Pz'    'POz'  'PPO2h'    'POO4'    'PO4h'    'PPO4h'    'POO6'    'PO6h'    'PPO8h'    'FFT9h'    'FC5'    'FT7'    'FT9'    'FCC5h'    'FTT7h' 'C5'    'T7'    'CCP5h'    'TTP7h'    'CP5'    'TP7'    'TPP7h'    'P5'    'P7'    'P9'    'P6'    'P8'    'P10'    'TPP8h'  'CP6'    'TP8'    'CCP6h'    'TTP8h'    'C6'    'T8'    'FCC6h'    'FTT8h'    'FC6'    'FT8'    'FT10'    'FFT10h'    'FC1' 'FC3'    'FCC1h'    'FCC3h'    'C1'    'C3'    'CCP1h'    'CCP3h'    'CPz'    'CP1'    'CP3'    'CPP1h'    'CPP3h'    'CPP5h'   'P1'    'P3'    'P2'    'P4'    'CPP2h'    'CPP4h'    'CPP6h'    'CP2'    'CP4'    'CCP2h'    'CCP4h'    'Cz'    'C2'    'C4'  'FCC2h'    'FCC4h'    'FC2'    'FC4'    'FFT7h'    'FFC5h'    'F5'    'FFC3h'    'F3'    'FFC1h'    'F1'    'FCz'    'Fz'  'FFC2h'    'F2'    'FFC4h'    'F4'    'FFC6h'    'F6'    'FFT8h'    'F7'    'AFF7h'    'AF5h'    'AF7'    'AF3h'    'Fp1'  'AFF1h'    'AFF2h'    'AFz'    'Fpz'    'AF4h'    'Fp2'    'AF6h'    'AF8'    'AFF8h'    'F8' 'Pz'    'RPA'    'T3'    'T4'    'T5' 'T6'    'T7'    'T8'    'TP7'    'TP8'    'TPP7h'    'TPP8h'    'TTP7h'    'TTP8h'    'Tp10'    'Tp9'};
% COLS = {'Average'      'Feedbacked signal'        'Stddev'    'Window num'    'Window size'};
% %select baseline file and check whether it contains information about DS
% [fname, pathname, index] = uigetfile('*.bin','Select baseline file'); %#ok<ASGLU>
% bl_file = fopen([pathname '/' fname]);
% bl_data_sz = fread(bl_file,2,'int');
%
% %grab info about DS
% %if there exists a header file, take the info out of it, excluding electrodes names
% %if it does not, prompt user about DS xml files (and take filter settings out of them) and
% %exp design file (and take info about window size out of it)
% if exist([pathname '/' 'exp_info.hdr'],'file')
%     exp_info_file = fopen([pathname '/' 'exp_info.hdr']);
%     s = fscanf(exp_info_file,'%c');
%     headers = strsplit(s,',');
%     if length(headers) > bl_data_sz(2) %if baseline does not contain DS records
%
%         %prompt the user about DS files or choose another baseline
%         inp = questdlg('The chosen file does not contain DS records. Choose DS xml settings or choose another baseline file?',...
%             '?','Choose DS XML settings','Choose another baseline','Choose XML settings');
%         switch inp
%             case 'Choose XML settings'
%
%                 %if the same baseline file - recalculate using filters
%                 exp_settings = load_exp_design_file;
%                 if exp_settings == 0
%                     return
%                 end
%
%             case 'Choose another baseline'
%                 %if another baseline, call this function again
%                 calculate_stats
%                 return
%
%
%         end
%
%
%     else
%         used_electrodes = intersect(lower(headers),lower(ELECTRODES));
%         other_cols = setdiff(lower(headers),used_electrodes);
%         possible_dss = setdiff(other_cols, lower(COLS));
%         %choose which DSs
%         [selection,ok] = listdlg('ListString',possible_dss,'PromptString','Select DS to plot');
%         if ok
%             dss = possible_dss(selection);
%         else
%             return
%         end
%     end
%
% end
%
%
% %select files to calculate
%
%
%
% end
% function [exp_settings] = load_exp_design_file
%     exp_xml = uigetfile('*.xml','Select file with experimental design');
%
%         nfs = NeurofeedbackSession;
%         nfs.LoadFromfile(exp_xml);
%         if length(nfs.derived_signals) < 2
%
%             answer = questdlg('The experiment file does not contain any information about derived signals','?','Select another file','Cancel','Select another file');
%             switch answer
%                 case 'Select another file'
%                     exp_settings = load_exp_design_file;
%                 case 'Cancel'
%                     exp_settings = 0;
%             end
%         else
%             dsignals = {};
%             %data_length = ??
%             %channels = ?
%             if ~nfs.sampling_frequency
%                 nfs.sampling_frequency = 1000;%???????
%             end
%             for ds = 1:length(nfs.derived_signals)
%                 signal = DerivedSignal(1,nfs.derived_signals{ds},nfs.sampling_frequency);
%             end
%
%         end
% end

% select_figure = figure('Tag','select_figure');
% cancel_btn = uicontrol(select_figure,'Tag','cancel_btn','String','Cancel','Position',[200 50 100 50]);
% ok_btn = uicontrol(select_figure,'Tag','ok_btn','String','OK','Position',[50 50 100 50]);
% add_files_btn = uicontrol(select_figure,'Tag','add_files_btn','String','Add files','Position',[400 400 100 50]);
% add_folders_btn = uicontrol(select_figure,'Tag','add_folders_btn','String','Add folders','Position',[400 300 100 50]);
% remove_files_btn = uicontrol(select_figure,'Tag','remove_files_btn','String','Remove files',[400 200 100 50]);
% %select_baseline_btn = uicontrol('Tag','select_baseline_btn');
% %select files and folders
%
% pr_gr = uibuttongroup(select_figure,'Tag','protocol_button_group','Position',[0 0 100 600]); %toggle buttons
%
%
% %select baseline (radiobutton)
%
%
% %recalculate
%
%
% % present graphs