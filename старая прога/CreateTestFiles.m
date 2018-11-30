function CreateTestFiles
t = [0.001:0.001:60];

sin8 = sin(2*8*pi*t);
sin9 = sin(2*9*pi*t);
sin10 = sin(2*10*pi*t);
sin11 = sin(2*11*pi*t);
sin12 = sin(2*12*pi*t);
sin13 = sin(2*13*pi*t);
sin14 = sin(2*14*pi*t);
sin15 = sin(2*15*pi*t);
sin16 = sin(2*16*pi*t);

baseline = randn(60000,32) + randn(60000,32);
csp_left = randn(60000,32) + randn(60000,32);
csp_right = randn(60000,32) + randn(60000,32);

left_ch = [9 10 15 20];
right_ch = [11 12 17 23];


for ch = left_ch
    baseline(:,ch) = baseline(:,ch) + 3*sin8'+ 2*sin12'+sin16';
    csp_left(:,ch) = csp_left(:,ch) + 3*sin8'+ 2*sin12'+sin16';
end

for ch = right_ch
    baseline(:,ch) = baseline(:,ch) + 3*sin8'+ 2*sin12'+sin16';
    csp_right(:,ch) = csp_right(:,ch) + 3*sin8'+ 2*sin12'+sin16';
end


f = fopen('1 baseline 60.bin','w');
fwrite(f,size(baseline),'int');
fwrite(f,baseline,'double');
fclose(f);

f = fopen('2 csp_right 60.bin','w');
fwrite(f,size(csp_right),'int');
fwrite(f,csp_right,'double');
fclose(f);

f = fopen('3 csp_left 60.bin','w');
fwrite(f,size(csp_left),'int');
fwrite(f,csp_left,'double');
fclose(f);




end