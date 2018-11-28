f =figure;
title = uicontrol('Parent',f,'Style','text','String','CSP_left_and_right','units','normalized','Position',[0.4 0.9 0.2 0.05]);
all_ch_text = uicontrol('Parent',f,'Style','text','String','All channels','units','normalized','Position',[0.1 0.9 0.2 0.05]);
selected_ch_text = uicontrol('Parent',f,'Style','text','String','Selected channels','units','normalized','Position',[0.7 0.9 0.2 0.05]); 
left_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Left','Position', [0.38 0.8 0.1 0.1],'Tag','select_left_ch','Callback',@SelectChannels);
center_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Center','Position', [0.46 0.8 0.1 0.1],'Tag','select_center_ch','Callback',@SelectChannels);
right_chb = uicontrol('Parent',f,'Style','checkbox','units','normalized','String','Right','Position', [0.56 0.8 0.1 0.1],'Tag','select_right_ch','Callback',@SelectChannels);
all_ch = uicontrol('Parent',f,'Style','listbox','Min',0,'Max',32,'units','normalized','Position',[0.05 0.1 0.3 0.8],'String',channels,'Tag','all ch list');
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

uiwait();
selected_ch.String
