function cell_metrics = half_peak_width(cell_metrics,session,spikes,spikes_all)
% function to compute the half peak width and the time to repolarization
% metric

% input:
%   wave:  a spike template waveform
%   sr: sampling rate

% returns:
% halfwidth_ms: halfwidth of the second positive peak of the wave in ms
% timeTorepolization: the time between the second peak and the decay to 25%
% of the peak. defined by 'Ardid et al. 2015 JNeurosci'

% if the template waveform has positive polarity (the positive peak is
% dominant) the output is NaN 

% by: Sara Mahallati
% Last Edited: 04 11 2020 


sr=session.extracellular.sr;
sr = sr/1000; % to be in ms
N_cells = length(spikes{1}.filtWaveform);

halfwidth_ms = NaN(1,N_cells);
timeTorepolarization = NaN(1,N_cells);
for i = 1:N_cells
    wave = spikes{1}.filtWaveform{i};
    % set the value to be NaN for positivie spikes

    if abs(max(wave)) < abs(min(wave)) 
        wave = interp(wave,1024); % upsample the waveforms

        [~, ind_neg_peak] = min(wave); %find negative peak
        wave_second_half = wave(ind_neg_peak:end); % cut the second half
        [second_positive_peak, indpeak] = max(wave_second_half); % find the peak
        half_max = second_positive_peak/2; % find half of the peak
        halfwidth_ms(i) = sum(wave_second_half>=half_max)/(sr*1024); %count the indices of where the wave is above half max
        %devide by sampling rate and upsample rate to get the time  
        
        quartile_decay = second_positive_peak-(second_positive_peak/4); %waveform decay of 25% from the peak
        timeTorepolarization(i) = sum(wave_second_half(indpeak:end)>=quartile_decay)/(sr*1024); %take the segment of the waveform from second peak to end, count the indices where it is above quartile decay value

    end
    
end

cell_metrics.peakHalfWidth = halfwidth_ms;
cell_metrics.timeTorepolarization = timeTorepolarization;
 
end