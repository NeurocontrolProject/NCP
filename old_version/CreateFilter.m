function filt = CreateFilter(band,sampling_frequency)
% creates cheby2 filter with 
% stopband1 = 1Hz, stopband2 = 50 Hz and passband = band and
% sampling_frequency = sampling_frequency
% Syntax: filt = CreateFilter(band, sampling_frequency)
% Inputs:
%       band - array of two doubles [low_frequency high_frequency]
%       sampling_frequency - double
% Output:
%       filt - digitalFilter
% 

filt = designfilt('bandpassiir','StopbandFrequency1',1,'PassbandFrequency1',band(1),'PassbandFrequency2',band(2),...
                            'StopbandFrequency2', 50, 'StopbandAttenuation1',30,'PassbandRipple',1,...
                            'StopbandAttenuation2',30,'DesignMethod','cheby2','SampleRate', sampling_frequency);