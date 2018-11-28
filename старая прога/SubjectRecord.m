classdef SubjectRecord < handle
    % SubjectRecord stores information about the experimental subject
    
    properties
        subject_name % human name
        acq_date % date of the experiment
        time_start % 
        time_stop
        folder_name
        nss_file_name % name of experimental electrode montage
 
    end 
   
    methods
        function self = SubjectRecord(self) %#ok<INUSD>
            self.subject_name       = 'Null';
            self.acq_date           = date;
            self.time_start         = datestr(now,'HH-MM-SS');
            self.time_stop          = 0;
            self.folder_name        = '';
            self.nss_file_name      = '';
        end
    end
end


