function eeg_stream()
% This function provides an interface for an eeg stream similar to one that NeoRec produces

global fname_datas
 global filename_position
 filename_position = 1;
fname_datas = {};

% show figure
f = figure('Position', [400, 400, 350,460],'Tag','stream control','name','Stream','NumberTitle','off','DeleteFcn',@CloseMainWindow);
l = uicontrol(f,'String','loop', 'Position', [10 430 100 20],'Style','checkbox','Tag','loop data','Value',1); 
p = uicontrol(f,'String','Start streaming','Position', [10 340 100 20],'Callback',@ct,'Tag','connect button','Enable','off'); 
a =  uicontrol(f,'String','Add file(s)','Position', [150 340 100 20],'Callback',@manage_files,'Tag','add files button'); 
lst = uicontrol(f,'String',{},'Position',[10 30 310 300],'Style','listbox', 'Tag','filenames list','Max',10); %#ok<*NASGU>
d = uicontrol(f,'String','Delete','Position',[10 10 50 20], 'Style','pushbutton','Tag','delete files button','Callback',@manage_files);
c = uicontrol(f,'String','Create outlet','Position',[10 370 150 50], 'Style','pushbutton','Tag','create outlet button','Callback',@create_outlet);
i = uicontrol(f,'String','Info','Position',[200 380 150 100],'Style','text','Tag','info text');
st = uicontrol(f,'String','Stop after each file','Position',[200 380 150 100],'Style','checkbox','Tag','stop after each file');

end


%--------------------------------------------------------------------------
function create_outlet(source,event) %#ok<INUSD>
% This callback function creates an lsl outlet.
% The parameters of the outlet are:
%       stream_name - 'NVX136_Data'
%       content_type = 'Data'
%       #channels - channels that are described in '.hdr' file
%       sampling_rate - size of the first file/duration of the first file
%       channel_format - 'cf_float32'
%       sourceid - path to the first file


global channel_count %number of channels
global chunk_size % 1 if sampling_frequency < 1000  else sampling_frequency/1000
global connected %boolean
global current_position %position in file
global filename_position %position on the list
global outlet %

current_position = 0;
filename_position = 1;
%create outlet
%assume that all files have the same number and order of channels
% (how to check if they don't?)
delete(outlet)
f = findobj('Tag','filenames list');
filenames = f.String;

if isempty(filenames)
    disp('Add files')
    return
end
if ~exist(filenames{1},'file')
    disp('Wrong path. File does not exist');
    return
end

[pathstr,name,ext] = fileparts(filenames{1});
if isempty(pathstr) || isempty(ext) || isempty(name)
    disp('Wrong filename')
    return
end
protocol_data = ReadEEGData(filenames{1});
[protocol,protocol_show_as, duration, channels]  = GetDataProperties(pathstr,filenames{1}); %#ok<ASGLU>
sampling_frequency = round(length(protocol_data)/duration);

if sampling_frequency > 1000
    chunk_size = round(sampling_frequency/1000);
    sampling_frequency = 1000;
else
    chunk_size = 1;
end
source_id = pathstr;

channel_count = length(channels);
lsllib = lsl_loadlib();
eeg_info = lsl_streaminfo(lsllib,'NVX136_Data', 'Data',channel_count, sampling_frequency,'cf_float32',source_id);
chns = eeg_info.desc().append_child('channels');

for label = channels
    ch = chns.append_child('channel');
    ch.append_child_value('label',label{1});
end
if ~isempty(outlet)
    delete(outlet);
end
outlet = lsl_outlet(eeg_info);
timer_push_data = timer('Name','push_data','TimerFcn', {@PushDataToLSL,outlet},'ExecutionMode','fixedRate','Period',1/sampling_frequency);
connected = 0;
start(timer_push_data);
c = findobj('Tag','create outlet button');
c.Enable = 'off';
c_b = findobj('Tag','connect button');
c_b.Enable = 'on';

end


%--------------------------------------------------------------------------
function ct(obj,event) %#ok<INUSD>
% Connects and disconnects.
% 
global connected
global filename_position
global current_position
global current_data_array
global fname_datas 
b = findobj('Tag','connect button');
f = findobj('Tag','filenames list');
st = findobj('Tag','stop after each file');

if ~connected
    b.String = 'Stop streaming';
    connected = 1;
    filename_position = f.Value;
    current_data_array = fname_datas{filename_position,2}';
    current_position = 1;
    f.Enable = 'inactive';
    
else
    connected = 0;
    %current_position = 0;
    b.String = 'Start streaming';
    f.Enable = 'on';
end
end


%--------------------------------------------------------------------------
function manage_files(source, event) %#ok<INUSD>
% Add and deletes files to and from the list
global fname_datas
global filename_position
f = findobj('Tag','filenames list');

filenames = f.String;

if strcmp(source.Tag,'add files button')
    [fnames, pathname, filterindex] = uigetfile('.bin','Select files to add','MultiSelect','on'); %#ok<ASGLU>
    if isnumeric(fnames) && fnames == 0
        return
    else
        if iscell(fnames) %several files
            for fname = fnames
                filenames{end+1} = strcat(pathname,fname{1});
                fname_data = ReadEEGData(strcat(pathname,fname{1}));
            fname_datas{end+1,1} = fname{1};
            fname_datas{end,2} = fname_data;
            end
        elseif ischar(fnames) %one file
            filenames{end+1} = strcat(pathname,fnames);
            fname_data = ReadEEGData(strcat(pathname,fnames));
            fname_datas{end+1,1} = fnames;
            fname_datas{end,2} = fname_data;
        end
        

        f.String = filenames;
        if filename_position
            f.Value =  filename_position;
        else
            filename_position = 1;
        end
    end
    
    
elseif strcmp(source.Tag,'delete files button')
    new_fnames = {};
    new_datas = {};
    for fname = 1:length(filenames)
        if isempty(find(f.Value == fname, 1)) %not selected
            new_fnames{end+1} = filenames{fname};
            new_datas{end+1,1} = fname_datas{fname,1};
            new_datas{end,2} = fname_datas{fname,2};
        end
    end

    f.String = new_fnames;
    if isempty(f.String)
        f.Value = 1;
    elseif filename_position <= length(f.String) && filename_position
    f.Value = filename_position;
    else
        f.Value = length(f.String);
    end
    
    fname_datas = new_datas;
end



end


%--------------------------------------------------------------------------
function next_file
% Starts transmitting the next file on the list
% Moves forward filename_position
global filename_position
global current_position
global current_data_array
global fname_datas
current_position = 1; %start of the file
l = findobj('Tag','loop data');

f = findobj('Tag','filenames list');
st = findobj('Tag','stop after each file');
ctb =findobj('Tag','connect button');
f = findobj('Tag','filenames list');
if st.Value == 1 && filename_position
    filename_position = 0;
    ctb.String = 'Start streaming';
    f.Enable = 'on';
    
elseif ~filename_position && ~isempty(f.String)
    filename_position = 1;
    f.Enable = 'inactive';
elseif filename_position == length(f.String) && l.Value %looped
    filename_position = 1;
    f.Enable = 'inactive';
    ctb.String = 'Start streaming';
elseif filename_position == length(f.String) || isempty(f.String)
    filename_position = 0;
    f.Enable = 'on';
    ct;
else
    filename_position = filename_position + 1;
end
if filename_position && filename_position <= length(f.String)
    f.Value = filename_position;
    current_data_array = fname_datas{filename_position,2}';
    
end


end


%--------------------------------------------------------------------------
function PushDataToLSL(timer_obj,event,outlet) %#ok<INUSL>
% Acts on timer, pushes a chunk of data into the outlet

global connected
global channel_count
global chunk_size
global current_position
global current_data_array
global filename_position


%%%%%%% if connected and outlet exists: push file
%%%%%%%% elseif outlet exists: push zeros
%%%%%%%% else
try
if isempty(ishandle(findobj('Tag','stream control')))
    if exist('timer_obj','var')
    stop(timer_obj);
    end
    clear('timer_obj');
    
    clear('outlet');
    return
end

if ~connected || ~current_position || ~outlet.have_consumers() || ~filename_position
    outlet.push_chunk(zeros(channel_count,chunk_size));
else
    %push data
    try
        if filename_position
            if current_position + chunk_size > size(current_data_array,2)
                next_file
                
            elseif outlet.have_consumers() && current_position
                outlet.push_chunk(current_data_array(:,current_position:current_position+chunk_size-1));
                current_position = current_position + chunk_size;
                
            end
        end
    catch
        245 %#ok<NOPRT>
    end
    

end
    catch
        257 %#ok<NOPRT>
end
% end
end


%--------------------------------------------------------------------------
function CloseMainWindow(source,event) %#ok<INUSD>
global outlet
% Closes the window
% (stops the transmission - not added yet)
button = questdlg('Stop the transmission?','?','Yes','No','No');
switch button
    case 'Yes'
        %delete(outlet)
        close(findobj('Tag','stream control'));
    otherwise
        return
end

end



