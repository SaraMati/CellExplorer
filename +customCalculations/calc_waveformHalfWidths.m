function cell_metrics = calc_waveformHalfWidths(cell_metrics,session,spikes,parameters)

% Extracts half widths of the first and second peak and the trough
% 
% input:
%   wave:  a spike template waveform
%   sr: sampling rate
  
% By Sara 
% 2021 10 25 from calc_waveform_metrics



filtWaveform = spikes{1}.filtWaveform;
timeWaveform = spikes{1}.timeWaveform{1};

sr_in=session.extracellular.sr;
N_cells = length(filtWaveform);

% filtWaveform = waveforms.filtWaveform;
% timeWaveform = waveforms.timeWaveform{1};
% timeWaveform_span = length(timeWaveform) * mean(diff(timeWaveform));
% sr = 1/mean(diff(timeWaveform))*1000;
oversampling = ceil(100000/sr_in);
sr = oversampling * sr_in;
timeWaveform = interp1(timeWaveform,timeWaveform,timeWaveform(1):mean(diff(timeWaveform))/oversampling:timeWaveform(end),'spline');

% reference is where the 0 time is
zero_idx = find(timeWaveform>=0,1);

trough_interval = [find(timeWaveform>=-0.25,1),find(timeWaveform>=0.25,1)]; % -10/40:10/40 => 

wave = [];


halfwidth_peak1 = NaN(1,N_cells);
halfwidth_peak2= NaN(1,N_cells);
halfwidth_trough = NaN(1,N_cells);

for m = 1:N_cells
    if ~any(isnan(filtWaveform{m}))
    wave = interp1(spikes{1}.timeWaveform{1},zscore(filtWaveform{m}),timeWaveform(1):mean(diff(timeWaveform)):timeWaveform(end),'spline');
    polarity = mean(wave(trough_interval(1):trough_interval(2))) - mean(wave([1:trough_interval(1),trough_interval(2):end]));
    if polarity > 0
        wave = -wave;
    end

    [MIN2,I2] = min(wave(trough_interval(1):trough_interval(2))); % trough_interval
    [MAX3,I3] = max(wave(1:I2+trough_interval(1)-1));
    [MAX4,I4] = max(wave(I2+trough_interval(1):end));

    
    indexes = I3:I2+I4+trough_interval(1)-1;
    
    
    half_max2 = MAX4/2; 
    wave_second_half = wave(I2+trough_interval(1):end);
    halfwidth_peak2(m) = sum(wave_second_half>=half_max2);
    
    half_max1 = MAX3/2; 
    wave_first_half = wave(1:I2+trough_interval(1)-1);
    halfwidth_peak1(m) = sum(wave_first_half>=half_max1); 
    

    half_trough = MIN2/2; 
    wave_peaktopeak = wave(indexes);
    halfwidth_trough(m) = sum(wave_peaktopeak<=half_trough); 

    end
end

cell_metrics.halfwidth_peakA = halfwidth_peak1/sr*1000;
cell_metrics.halfwidth_peakB = halfwidth_peak2/sr*1000;
cell_metrics.halfwidth_trough = halfwidth_trough/sr*1000;

end