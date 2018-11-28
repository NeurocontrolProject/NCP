% This script connects to wireless eeg device

if exist('eeg','var') && isvalid(eeg)
    eeg.DoNothing;
    if isvalid(eeg)
        return
    end
end

close all;
clear();
clear classes();

warning('on'); %#ok<WNON>
warning('off','backtrace');
eeg = EEGLSL;
eeg.RunInterface('name','SmartBCI_Data');
