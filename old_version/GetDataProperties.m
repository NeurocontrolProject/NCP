function [protocols, protocols_show_as,durations, channels,settings_file] = GetDataProperties(pathname,fnames)
% This function returns settings and data of selected experiment
% Input:
%       pathname - string; folder name
%       filenames - string or cell of strings; files, containing experimental data
% Output:
%       protocols - the cell of protocol_names
%       protocol_show_as - the cell of show_as
%       durations - the array of protocol durations
%       channels - cell of channel labels (derived from ssd_exp_info.hdr or
%                   csp_exp_info.hdr
%       settings_file - full filename of 'Exp_design.xml' if exists
%       
protocols = {};
protocols_show_as = {};
durations = [];
channels = {};

if ischar(fnames) %if there's only one fname
    [a, b, c]= fileparts(strcat(pathname,fnames)); %#ok<ASGLU>
    if verLessThan('matlab','8.1')
        s = regexp(b,' ','split');
    else
        s = strsplit(b);
    end
    protocols{end+1} = s{2};
    try %#ok<TRYNC>
    protocols_show_as{end+1} = s{3};
    end
    durations(end+1) = str2double(s{end});
else
    for f = fnames
        
        
        [a, b, c]= fileparts(strcat(pathname,f{1})); %#ok<ASGLU>
        if verLessThan('matlab','8.1')
            s = regexp(b,' ','split');
        else
            s = strsplit(b);
        end
        if length(s) > 1
        protocols{end+1} = s{2};
        try %#ok<TRYNC>
        protocols_show_as{end+1} = s{3};
        end
        durations(end+1) = str2double(s{end});
        end
    end
end

all_fs = dir(pathname);
%fetch the names of the data columns
for n = 1:length(all_fs)
    if strcmp(all_fs(n).name,'ssd_exp_info.hdr') || strcmp(all_fs(n).name,'csp_exp_info.hdr')
        sh = fopen(strcat(pathname,'\',all_fs(n).name),'r');
        ch_str = fscanf(sh,'%c');
        if verLessThan('matlab','8.1')
            channels = regexp(ch_str,',','split');
        else
            channels = strsplit(ch_str,',');
        end
        fclose(sh);
    elseif strcmp(all_fs(n).name,'Exp_design.xml')
        settings_file = strcat(pathname,'\',all_fs(n).name);
    end
end

end