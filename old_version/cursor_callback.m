function output_txt = cursor_callback(obj,event_obj) %#ok<INUSD>
%%%% Displays the position of the data cursor
%%% Allows to select channels in the plot
%%% Inputs:
%%%         obj          Currently not used (empty)
%%%%        event_obj    Handle to event object
%%% Output:
%%%     output_txt   Data cursor text string (string or cell array of strings).

% pos = get(event_obj,'Position');
% output_txt = {['X: ',num2str(pos(1),4)],...
%     ['Y: ',num2str(pos(2),4)]};
% 
% %%%%% If there is a Z-coordinate in the position, display it as well
% if length(pos) > 2
%     output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
% end
cursor_obj = datacursormode();
s = getCursorInfo(cursor_obj);
output_txt = s.Target.DisplayName;