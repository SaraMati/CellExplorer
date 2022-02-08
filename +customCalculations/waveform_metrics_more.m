function cell_metrics = waveform_metrics_more(cell_metrics,session,spikes)
% function to compute the half peak width and the time to repolarization
% metric and more 

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
% Last Edited: 08 02 2022 

sr_in=session.extracellular.sr;
oversampling = ceil(100000/sr_in);
sr = oversampling * sr_in;

timeWaveform = spikes{1}.timeWaveform{1};
timeWaveform = interp1(timeWaveform,timeWaveform,timeWaveform(1):mean(diff(timeWaveform))/oversampling:timeWaveform(end),'spline');
trough_interval = [find(timeWaveform>=-0.25,1),find(timeWaveform>=0.25,1)]; % -10/40:10/40 =>


N_cells = length(spikes{1}.filtWaveform);

timeTorepolarization = NaN(1,N_cells);

halfwidth_a = NaN(1,N_cells);
halfwidth_b = NaN(1,N_cells);
halfwidth_trough = NaN(1,N_cells);

repolarization_slope = NaN(1,N_cells);
recovery_slope = NaN(1,N_cells);

peak_trough_ratio = NaN(1,N_cells);
for i = 1:N_cells
    if ~any(isnan(filtWaveform{m}))
    wave = spikes{1}.filtWaveform{i};
    wave = interp1(waveforms.timeWaveform{1},wave,timeWaveform(1):mean(diff(timeWaveform)):timeWaveform(end),'spline');
    if cell_metrics.polarity(i) > 0
        wave = -wave;
    end
    % set the value to be NaN for positivie spikes

%     if abs(max(wave)) < abs(min(wave)) 
%         wave = interp(wave,1024); % upsample the waveforms
    [trough,ind_neg] = min(wave(trough_interval(1):trough_interval(2))); %trough
    wave_second_half = wave(ind_neg+trough_interval(1):end-21); % cut the second half
    [peak2,ind_peak2] = max(wave_second_half); % -21 samples = 0.2 ms of the end of waveform  -21 samples before end to make space for the 20 recovery samples below, if the peak B is at the end of the waveform
    half_max2 = peak2/2; % find half of the peak
    halfwidth_b(1,i) = sum(wave_second_half>=half_max2); %count the indices of where the wave is above half max * sr is in seconds; *1000 in ms
    quartile_decay = peak2-(peak2/4); %waveform decay of 25% from the peak
    timeTorepolarization(1,i) = sum(wave_second_half(indpeak2:end)>=quartile_decay); %take the segment of the waveform from second peak to end, count the indices where it is above quartile decay value

%         [~, ind_neg_peak] = min(wave); %find negative peak
%         wave_second_half = wave(ind_neg_peak:end); % cut the second half
%         [second_positive_peak, indpeak] = max(wave_second_half); % find the peak
%         half_max = second_positive_peak/2; % find half of the peak
%         halfwidth_ms(i) = sum(wave_second_half>=half_max)/(sr*1024); %count the indices of where the wave is above half max
        %devide by sampling rate and upsample rate to get the time  
        
%         quartile_decay = second_positive_peak-(second_positive_peak/4); %waveform decay of 25% from the peak
%         timeTorepolarization(i) = sum(wave_second_half(indpeak:end)>=quartile_decay)/(sr*1024); %take the segment of the waveform from second peak to end, count the indices where it is above quartile decay value

%     end
    [peak1,ind_peak1] = max(wave(1:ind_neg+trough_interval(1)-1));

        
    indexes = ind_peak1:ind_neg+trough_interval(1)+ind_peak2;
    
      
    half_max1 = peak1/2; 
    wave_first_half = wave(1:ind_neg+trough_interval(1)-1);
    halfwidth_a(1,i) = sum(wave_first_half>=half_max1); 
    

    half_trough = trough/2; 
    wave_peaktopeak = wave(indexes);
    halfwidth_trough(1,i) = sum(wave_peaktopeak<=half_trough); 
    
    
    repolarization_samples = 0.2*1e-3*sr; % take 0.2 ms window for linear regression
    repolarization_start_ind = ind_neg+trough_interval(1);
    repolarization_end_ind = ind_neg+trough_interval(1)+repolarization_samples;
    wave_for_linreg = wave(repolarization_start_ind:repolarization_end_ind);
    t_repol = timeWaveform(repolarization_start_ind:repolarization_end_ind);
    Mdl_repol = fitlm(t_repol',wave_for_linreg');
    repolarization_slope(1,i) = Mdl_repol.Coefficients.Estimate(2) * 1e-6;
    
    
    recovery_samples = 0.2*1e-3*sr; % take the waveform for a window of 90 microseconds after peakB
    recovery_start_ind = trough_interval(1)+ind_neg+ind_peak2; 
    wave_for_linreg_recovery = wave(recovery_start_ind:recovery_start_ind+recovery_samples);
    t_recov = timeWaveform(recovery_start_ind:recovery_start_ind+recovery_samples);
    Mdl_recov = fitlm(t_recov,wave_for_linreg_recovery);
    recovery_slope(1,i) = Mdl_recov.Coefficients.Estimate(2) * 1e-6;
    
    peak_trough_ratio(1,i) = abs(peak2/trough);
    ab_ratio(1,i) = (peak2-peak1)./(peak2+peak1);

    figure
    hold on
    plot([-(ind_neg+trough_interval(1)-1)+1:1:0,1:1:(length(wave)-(ind_neg+trough_interval(1)-1))]/sr*1000,wave,'Color',[0,0,0,0.1],'linewidth',2), axis tight
    plot(0,trough,'.b') % Min
    plot((-(ind_neg+trough_interval(1)-1)+ind_peak1)/sr*1000,peak1,'.r') % Max
    plot(ind_peak2/sr*1000,peak2,'.g') % Max
    plot(t_repol-timeWaveform(repolarization_start_ind),Mdl_repol.Fitted,'k') % linear fit for repolarization
    plot(t_recov-timeWaveform(repolarization_start_ind),Mdl_recov.Fitted,'k') % linear fit for recovery
    title('Waveforms'),xlabel('Time (ms)'),ylabel('Z-scored')
    end
        

end

cell_metrics.timeTorepolarization = timeTorepolarization;

cell_metrics.halfwidth_a = halfwidth_a/sr*1000;
cell_metrics.halfwidth_b = halfwidth_b/sr*1000;
cell_metrics.halfwidth_trough = halfwidth_trough/sr*1000;


cell_metrics.SlopeRepolarization = repolarization_slope;
cell_metrics.SlopeRecovery = recovery_slope;

cell_metrics.bTrough_ratio = peak_trough_ratio;
cell_metrics.ab_ratio_nonZ = ab_ratio;


end