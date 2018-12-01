function [robot_path, new_robot_position,dx,dy] = CorrectRobotPosition(b,velocity_constant,robot_position,ch1,ch2)
% Recalculates the robot position
% Inputs:
%       b - the distance between wheels
%       velocity_constant - the velocity
%       robot_position[x,y,phi] - x,y - coordinates, phi - angle
%       ch1 - left wheel movement
%       ch2 - right wheel movement
% Outputs:
%       robot_path[xt yt] - new x and y 
%       new_robot_position[x, y, phi] - new x,y,phi
%       dx,dy - delta x, delta y
if ~isempty(robot_position)
    x = robot_position(1);
    y = robot_position(2);
    phi = robot_position(3);
else
    x = 0;
    y = 0;
    phi = pi/2;
end

if abs(ch1 - ch2) < eps %if the velocities of the right and the left wheels are equal
    deltaphi = phi;
    dp = mod(deltaphi,2*pi);
    if abs(dp) < eps
        dy = 0;
        dx = velocity_constant;
    elseif abs(dp - pi) < eps
        dy = 0;
        dx = -velocity_constant;
    elseif abs(dp - pi/2) < eps
        dx = 0;
        dy = -velocity_constant;
    elseif abs(dp - 3*pi/2) < eps
        dx = 0;
        dy = velocity_constant;
    elseif dp > 0 && deltaphi < pi/2
        dx = velocity_constant*sin(deltaphi);
        dy = -velocity_constant*cos(deltaphi);
    elseif dp > pi/2 && deltaphi < pi
        dx = -velocity_constant*sin(deltaphi);
        dy = -velocity_constant*cos(deltaphi);
    elseif dp > pi && deltaphi < 3*pi/2
        dx = -velocity_constant*sin(deltaphi);
        dy = velocity_constant*cos(deltaphi);
    elseif dp > 3*pi/2 && deltaphi < 2*pi
        dx = velocity_constant*sin(deltaphi);
        dy = velocity_constant*cos(deltaphi);
    end

else
    deltaphi = velocity_constant*(ch2-ch1)/b + phi;
dx = b/2*velocity_constant*(ch2+ch1)/(ch2-ch1)*(sin(deltaphi)-sin(phi));
dy = b/2*velocity_constant*(ch2+ch1)/(ch2-ch1)*(cos(deltaphi)-cos(phi));
end
xt = x + dx;
yt =  y - dy;

new_robot_position = [xt yt deltaphi];
robot_path = [xt yt];
    

end