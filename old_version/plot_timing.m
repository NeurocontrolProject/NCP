function plot_timing(eeg)
figure;
stem(eeg.fb_timing);
line('XData',1:length(eeg.fb_timing),'YData',eeg.fb_refresh_rate*ones(1,length(eeg.fb_timing)),'Color',[1 0 0]);
title('feedback');
ylabel('Running time, s');
xlabel('@Refresh_FB calls');

figure;
semilogy(1:length(eeg.chunk_sizes),eeg.chunk_sizes,'r',1:length(eeg.chunk_sizes),eeg.queue_size,'g');
line('XData',1:length(eeg.chunk_sizes),'YData',eeg.current_window_size*ones(1,length(eeg.chunk_sizes)),'Color',[0 0 0]);
legend({'Chunk_sizes','Queue size'});

figure;
stem(eeg.plot_timing);
line('XData',1:length(eeg.plot_timing),'YData',eeg.plot_refresh_rate*ones(1,length(eeg.plot_timing)),'Color',[1 0 0]);

title('plot');
ylabel('Running time, s');
xlabel('@PlotEEG calls');

figure;
stem(eeg.receive_timing);
line('XData',1:length(eeg.receive_timing),'YData',eeg.data_receive_rate*ones(1,length(eeg.receive_timing)),'Color',[1 0 0]);
title('receive');
ylabel('Running time, s');
xlabel('@Receive calls');
