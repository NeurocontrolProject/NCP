function SelectChannels(src,event) %#ok<INUSD>
% This callback function allows to select a subset of channels
% Checks all odd channels when checkbox 'select left channels' is on
% Checks all even channels when checkbox 'select right channels' is on
% Checks all 'z' channels when checkbox 'select center channels' is on
all_ch = findobj('Tag','all ch list');
selected_ch = findobj('Tag','selected ch list');
all_ch.String = unique(all_ch.String);
if strcmp(src.Tag,'select_left_ch')
    if src.Value %adding all left channels to selected
        %look for left channels
        number_of_channels = length(all_ch.String);
        ch = number_of_channels;
        while ch > 0
            
            s = all_ch.String{ch};

            idx = regexp(s,'\d+$', 'once');
            if ~isempty(idx)
                num = str2num(s(idx:end)); %#ok<ST2NM>
                if mod(num,2) %odd
                    selected_ch.String = union(selected_ch.String,s); %add this channel to selected
                    all_ch.String = setdiff(all_ch.String,s); %delete it from all channels
                    
                end
            end
            ch = ch-1;
        end
    else %deselecting all left channels
        number_of_channels = length(selected_ch.String);
        for ch = number_of_channels:-1:1
            s = selected_ch.String{ch};
            idx = regexp(s,'\d+$', 'once');
            if ~isempty(idx)
                num = str2num(s(idx:end)); %#ok<ST2NM>
                if mod(num,2) %odd
                    all_ch.String = union(all_ch.String,s); %add this channel to all channels
                    selected_ch.String = setdiff(selected_ch.String,s); %and delete it from selected
                end
            end
        end
    end
    
elseif strcmp(src.Tag,'select_center_ch')
    if src.Value %select center channels
        number_of_channels = length(all_ch.String);
        for ch = number_of_channels:-1:1
            s = all_ch.String{ch};
            idx = regexp(s,'z$', 'once');
            if ~isempty(idx)
                selected_ch.String = union(selected_ch.String,s); %add this channel to selected
                all_ch.String = setdiff(all_ch.String,s); %delete it from all channels
                
            end
        end
    else %deselect center channels
        number_of_channels = length(selected_ch.String);
        for ch = number_of_channels:-1:1
            s = selected_ch.String{ch};
            idx = regexp(s,'z$', 'once');
            if ~isempty(idx)
                all_ch.String = union(all_ch.String,s); %add this channel to all channels
                selected_ch.String = setdiff(selected_ch.String,s); %and delete it from selected
                
            end
        end
    end
elseif strcmp(src.Tag,'select_right_ch')
    if src.Value %select all right channels
        number_of_channels = length(all_ch.String);
        for ch = number_of_channels:-1:1
            s = all_ch.String{ch};
            idx = regexp(s,'\d+$');
            if ~isempty(idx)
                num = str2num(s(idx:end)); %#ok<ST2NM>
                if ~mod(num,2) %even
                    selected_ch.String = union(selected_ch.String,s);%add channel to selected
                    all_ch.String = setdiff(all_ch.String,s); % delete it from all channels
                end
            end
        end
    else %deselect all right channels
        number_of_channels = length(selected_ch.String);
        for ch = number_of_channels:-1:1
            s = selected_ch.String{ch};
            idx = regexp(s,'\d+$');
            if ~isempty(idx)
                num = str2num(s(idx:end)); %#ok<ST2NM>
                if ~mod(num,2) %even
                    all_ch.String = union(all_ch.String,s); %add channel to all channels (deselected)
                    selected_ch.String = setdiff(selected_ch.String,s); %delete it from selected
                end
            end
        end
    end
elseif strcmp(src.Tag,  'select_btn')
    if ~isempty(all_ch.String)
        selected = all_ch.String(all_ch.Value);
        all_ch.String = setdiff(all_ch.String,selected); % delete channels from all channels
        selected_ch.String = union(selected_ch.String, selected); %add them to selected
        
    end
    all_ch.Value = 1;
    selected_ch.Value = 1;
elseif strcmp(src.Tag,'deselect_btn')
    if ~isempty(selected_ch.String)
        deselected = selected_ch.String(selected_ch.Value);
        all_ch.String =union(all_ch.String,deselected); %add channels to all channels
        selected_ch.String = setdiff(selected_ch.String,deselected); %delete from selected
    end
    all_ch.Value = 1;
    selected_ch.Value = 1;
end
end