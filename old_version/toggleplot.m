function toggleplot(src,eventdata) %#ok
% This callback function allows to highlight selected subplots (results of CSP)
% Inputs:
%       src - subplot to toggle
%       eventdata - mouseclick
%


global selected

select = 1;
fig = get(src,'Parent');
ch = get(fig,'Children');

for k = 1:length(ch)
    if strcmp(get(ch(k),'Tag'),'Selection')
        delete(ch(k))
        t = get(fig,'Title');
        parent_idx = get(t,'String');
        idx = strsplit(parent_idx,':');
        selected = selected(~strcmp(selected,idx{1}));
        select = 0;
        break;
    end
end


if select
    t = get(fig,'Title');
    parent_idx = get(t,'String');
    idx = strsplit(parent_idx,':');
    selected{end+1} = idx{1};
    ang=0:0.01:2*pi;
    get_x = get(fig,'XLim');
    x = (get_x(2)+get_x(1))/2;
    get_y = get(fig,'YLim');
    y = (get_y(2)+get_y(1))/2;
    xp = get_x(2)*cos(ang);
    yp = get_y(2)*sin(ang);
    plot(fig,x+xp,y+yp,'Color',[0.5 0 1],'LineWidth',3,'Tag','Selection');
end
ok_btn = findobj('Tag','SelectHeadsBtn');
if ~isempty(selected)
    set(ok_btn,'enable','on');
else
    set(ok_btn,'enable','off');
end

end