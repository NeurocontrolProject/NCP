  bluetooth_connection  = Bluetooth('Nerv',1);
  
    fopen(bluetooth_connection);
    path = [0;0];
    position = [0 0 0];
    velocity_constant = 9;
    b = 15;
    fig_robot_position = figure('Visible','on');
    fig_robot = plot(0);
    fig_robot.Parent.DataAspectRatio = [1,1,1];
for i = 1:20
  
    % (6,0) - 2 bytes, message length (inverse) except itself
    % 128 = 0x80 - message writing TO nxt
    % 9 - writing to "mailbox" of nxt (others are for direct commands)
    % 0 - mailbox number, corresponds to "mailbox1" in nxt
    % 2 - 1 byte, length of message to mailbox
    % last 2 bytes are message itself

    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128+32]));   
    pause(10.25)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
end
b = 15;
velocity_constant = 9;
fig_robot_position = figure('Visible','on');

fig_robot = plot(0);
fig_robot.Parent.DataAspectRatio = [1,1,1];

path = [0;0];
position = [0 0 pi/2];
ch1 = 0;
ch2 = 1;
% fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128+32*ch1 128+32*ch2]));
% pause(1)
% fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
for i = 1:9
    [n_path,position,dx,dy] = CorrectRobotPosition(b,velocity_constant,position,ch1,ch2);
    path = [path, n_path'];
    PlotRobotPath(fig_robot, path)
end

ch1 = 128;
ch2 = 160;
for i = 1:15
   
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 ch1 ch2]));
    pause(0.5)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
    [n_path,position,dx,dy] = CorrectRobotPosition(b,velocity_constant,position,ch1,ch2);
    path = [path, n_path'];
    PlotRobotPath(fig_robot, path)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 ch2 ch1]));
    pause(0.5)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
    [n_path,position,dx,dy] = CorrectRobotPosition(b,velocity_constant,position,ch1,ch2);
    path = [path, n_path'];
    PlotRobotPath(fig_robot, path)
end
fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128])); %78x40

ch1 = 128;
ch2 = 192;
for i = 1:15
   fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 ch2 ch1]));

    pause(0.5)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
    [n_path,position,dx,dy] = CorrectRobotPosition(b,velocity_constant,position,ch1,ch2);
    path = [path, n_path'];
    PlotRobotPath(fig_robot, path)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 ch1 ch2]));
    pause(0.5)
    fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));
    [n_path,position,dx,dy] = CorrectRobotPosition(b,velocity_constant,position,ch1,ch2);
    path = [path, n_path'];
    PlotRobotPath(fig_robot, path)
end



%----------
fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128+32 128+32]));
pause(0.5)
fwrite(bluetooth_connection,uint8([6 0 128 9 0 2 128 128]));