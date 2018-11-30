function [data] = ReadEEGData(fname)
% Reads *.bin file into array
% Input:
%       fname - string
% Output:
%       data - array(samples,data_columns)
%
if nargin < 1
    disp('Filename is not specified')
    return
elseif ~ischar(fname)
    disp('The parameter is not string')
    return
elseif ~exist(fname,'file')
    disp('Cannot find the file')
    return
end

f = fopen(fname,'r','n','US-ASCII');
data_sz = fread(f,2,'int');
data = fread(f,data_sz','double'); 
fclose(f);


end

 