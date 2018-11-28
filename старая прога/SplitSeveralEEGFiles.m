function SplitSeveralEEGFiles()
% This function asks about several *.bin eeg files and calls SplitEEGFile 
% for each of them
%%% ask about files
[filename,pathname,filterindex] = uigetfile('*.bin','Select files to split','.','Multiselect','on'); %#ok<ASGLU>


%%% ask about partsize
 partsize = 0;
    while ~partsize
        q = inputdlg('What size the pieces should be?','Piece size', 1,{'10'});
        if isnan(str2double(q))
            partsize = 0;
        else
            partsize = str2double(q);
        end
    end

%%% split and write
if ischar(filename)
    SplitEEGFile(strcat(pathname,'\',filename),partsize);
else
for f = 1:length(filename)
    SplitEEGFile(strcat(pathname,'\',filename{f}),partsize);
end
end

