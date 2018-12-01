
function SplitEEGFile(fname,partsize)
%%% Splits a *.bin eeg file into several
%%% Exits if fname is not specified
%%% Input:
%%%      fname - string
%%%      partsize - number of seconds, 

%
if nargin < 1 || ~ischar(fname)
    return
end
d = ReadEEGData(fname);


%%% determine sampling frequency 
[f, n] = fileparts(fname);
[~, ~, dr, ~, ~] = GetDataProperties(f,n);
Fs = size(d,1)/dr;




%%%ask what size filepieces should be
if nargin < 2
    partsize = 0;
    while ~partsize
        q = inputdlg('The file length is 60 seconds. What size the pieces should be?','Piece size', 1,{'10'});
        if isnan(str2double(q))
            partsize = 0;
        else
            partsize = str2double(q);
        end
    end
end
 %%%create a folder to write
if ~exist(strcat(f,'\',n,' split'),'dir')
    mkdir(strcat(f,'\',n,' split'))
end
chdir(strcat(f,'\',n,' split'))
%%% generate files and filenames to write

upper = ceil(size(d,1)/(partsize*Fs));
 
 for fi = 1:upper
     if size(d,1) < fi*partsize*Fs
         filedata = d((fi-1)*partsize*Fs+1:end,:);
         to_append = strcat(num2str((fi-1)*partsize),'-',num2str(size(d,1)/Fs));
     else
         filedata = d((fi-1)*partsize*Fs+1:fi*partsize*Fs,:);
         to_append = strcat(num2str((fi-1)*partsize),'-',num2str(fi*partsize));
     end
     filename = [n,' ',to_append,'.bin'];
     f = fopen(filename,'w');
     fwrite(f,size(filedata),'int');
     fwrite(f,filedata, 'double');
     fclose(f);
     
end



end