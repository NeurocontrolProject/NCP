function delay_measurement()
eeg = EEGLSL;
eeg.derived_signals{1} = DerivedSignal;
eeg.derived_signals{2} = DerivedSignal;
eeg.derived_signals{1}.ring_buff = circVBuf(4000,32,0);
eeg.derived_signals{1}.spatial_filter = ones(32,1);
eeg.derived_signals{1}.signal_name = 'raw';
eeg.derived_signals{1}.channels_indices = 1:32;
eeg.derived_signals{2}.ring_buff = circVBuf(4000,1,0);
eeg.derived_signals{2}.spatial_filter = ones(32,1);
eeg.derived_signals{2}.channels_indices = 1:32;
eeg.derived_signals{2}.UpdateTemporalFilter;
eeg.current_window_size = 100;
eeg.fb_type = 'color';
figure(eeg.fig_feedback);
set(eeg.fig_feedback, 'OuterPosition', [-1280 0 1280 1024]);
eeg.fig_feedback.Color = [0 0 0];
eeg.feedback_protocols = {RealtimeProtocol};
eeg.current_protocol = 1;
dat = 16*ones(32,100);
tic
%disp ('1')
% eeg.derived_signals{1}.Apply(dat);
% eeg.derived_signals{2}.Apply(dat);
% eeg.UpdateFeedbackSignal;
% eeg.RefreshFB;

tic
for ds = 1:length(eeg.derived_signals)
eeg.derived_signals{ds}.Apply(dat);
end
toc

close(eeg.fig_feedback);
end