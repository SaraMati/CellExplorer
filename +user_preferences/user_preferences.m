function preferences = user_preferences(preferences,session)
% This is an example file for generating your own preferences for ProcessCellMetrics part of CellExplorer
% Please follow the structure of preferences_ProcessCellMetrics.m

% e.g.:

% Waveform
% preferences.waveform.nPull = 600;               % number of spikes to pull out (default: 600)
% preferences.waveform.wfWin_sec = 0.004;         % Larger window of the waveform for filtering (to avoid edge effects). Total width in seconds [default 4ms]
% preferences.waveform.wfWinKeep = 0.0008;        % half width of the waveform. In seconds [default 0.8ms]


preferences.putativeCellType.troughToPeak_boundary = 0.56; %0.525; % Narrow interneuron assigned if troughToPeak <= 0.425ms
preferences.waveform.wfWin_sec = 0.004;         % Larger window of the waveform for filtering (to avoid edge effects). Total width in seconds [default 4ms]
preferences.waveform.wfWinKeep = 0.00128;        % half width of the waveform. In seconds [default 0.8ms]
%preferences.waveform.showWaveforms = true;

disp('User preferences loaded successfully')

end
