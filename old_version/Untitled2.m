i = 1;
for f0 = 8:0.5:20
    pp(1,:) = [f0-3,f0-1];
    pp(2,:) = [f0-1, f0+1];
    pp(3,:) = [f0+1, f0+3];
    for f = 1:3
        filt = CreateFilter(pp(f,:),1000);
        x = filtfilt(filt,all);
        C{f} = x*x'/size(x,2);
        C{f} = C{f} * 0.1*trace(C{f})/size(C{f},1)*eye(size(C{f}));
    end
    try
        [v e] = eig(C{2},0.5 * (C{1} + C{3}),'chol');
        [u,s,v] = svd((C{1} + C{3})^(-1)*C{2});
        [mxv, mxi] = max(diag(e));
        mxi = 1;
        mxv = s(1,1);
        SSD(i) = mxv;
        V(:,i) = u(:,mxi);
        G(:,i) = u(mxi,:);
        Fr(i) = f0; %frequencies
        Rng(i,:) = pp(2,:); % band
        i = i+1;
    end
    hh = figure;
    plot(Fr,SSD); xlabel('frequency, Hz');
    annotation('textbox', [0.2,0.8,0.1,0.1],'String', {'Two left clicks and Enter to select range.','Backspace to delete last point','Right click to finish'});
    
    F = getpts(hh);
    if length(F) == 1
        peaks_found = 1; %#ok<NASGU>
        close(hh);
        %break;
    end
    close(hh);
    
    left_point = min(F);
    right_point = max(F);
    
    ind = (find(Fr>=left_point & Fr<=right_point));
    [~, ind_max] = max(SSD(ind));
    middle_point = ind(ind_max);
    disp(strcat(num2str(Fr(middle_point)),' Hz'));
    channel_mapping(ds) = figure;
    stem(G(:,middle_point));
    set(get(channel_mapping,'Children'),'XTick',(1:1:length(self.used_ch)));
    set(get(channel_mapping,'Children'),'XTickLabel',self.used_ch(:,1));
    %find the largest SSD for the middle point
    w_ssd  = V(:,middle_point);
    %                         w =1-diag(w_ssd);
    %                         if w == ones(size(w))
    %                             break
    %                         end
    %x_raw = x_raw * w;
    hh1 = figure; %#ok<NASGU>
    StandChannels = load('StandardEEGChannelLocations.mat');
    rearranged_map = rearrange_channels(G(:,middle_point),self.used_ch, StandChannels.channels);
    topoplot(rearranged_map, StandChannels.channels, 'electrodes', 'labelpoint', 'chaninfo', StandChannels.chaninfo);
    
    %b_ssd = B(middle_point,:);
    %a_ssd = A(middle_point,:);
    for k=1:length(w_ssd)
        %self.derived_signals{1}: the first DS is ALWAYS RAW signal
        chan_w{k,1} = self.derived_signals{1}.channels{k};
        chan_w{l,2} = w_ssd(k);
    end;
end