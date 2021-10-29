function cell_metrics = label_CorticalLayer(cell_metrics,session,spikes,parameters)
% function to label cells with the layers that electrodes were registered to

% input: spike times in seconds 
% returns: 
% Cortical depth and cortical layer from the file in each folder

% last edit: 2021 10 25
% by Sara Mahallati


    
    channels_layers = readmatrix('channels_layers.txt');
    Channel_maxwaveform = cell_metrics.maxWaveformCh1';        
    cell_metrics.CorticalLayer = channels_layers(Channel_maxwaveform,2)';
    cell_metrics.CorticalDepth = channels_layers(Channel_maxwaveform,3)'; % which is the same as:
%     cell_metrics.CorticalDepth = session.extracellular.probeDepths(Channel_maxwaveform)'; 

end
