classdef FeedbackManager < handle
    % This class stores information about feedback
    % I.e. the statistics for the derived signals, the window sizes for the 
    % protocols, the records.
    % The instance sets in eeglsl.UpdateFeedbackSignal
    %
    properties
        standard_deviation %array of stds
        average %array of averages
        window_size %samples
        feedback_vector %the current feedback value
        feedback_records % circVBuf of 
                        % 1 - index of feedbacked signal (in range 2:length(eeglsl.derived_signals)
                        % 2 - feedback value (feedback_vector) 
                        % 3 - average to calculate feedback 
                        % 4 - standard deviation to calculate feedback 
                        % 5 - window size 
                        % 6 - window number 
                        % 7 - discrete feedback (0 or 1)
        
        
        discrete_fb_records % array of ones and zeros
        discrete_fb_threshold % threshold to count discrete feedback
        discrete_fb_delta_t %if delta t passes without successful records (>= threshold), the threshold is lowered. Not used
    end
    
    methods
        function self = FeedbackManager(self) %#ok<INUSD>
            self.window_size            = 10;
             self.feedback_vector        = zeros(1,1);
                 self.standard_deviation     = ones(1,1);
                 self.average                = zeros(1,1);
            
        end


    end
    
end