function PlotRobotPath(a, path)
% Plots the path of the robot
% Inputs:
%       a - axis handle
%       path(2,:) - xs and ys

set(a,'XData',path(1,:), 'YData',path(2,:));

end