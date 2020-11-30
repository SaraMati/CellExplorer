function preferences = user_preferences(preferences,session)
% This is an example file for generating your own preferences for ProcessCellMetrics part of CellExplorer
% Please follow the structure of preferences_ProcessCellMetrics.m

% e.g.:
% preferences.waveform.nPull = 600;            % number of spikes to pull out (default: 600)
% preferences.waveform.wfWin_sec = 0.004;      % Larger size of waveform windows for filterning. total width in ms
% preferences.waveform.wfWinKeep = 0.0008;     % half width in ms
% preferences.waveform.showWaveforms = true;

preferences.putativeCellType.troughToPeak_boundary = 0.56; %0.525; % Narrow interneuron assigned if troughToPeak <= 0.425ms
preferences.waveform.wfWin_sec = 0.004;         % Larger size of waveform windows for filterning. total width in seconds
preferences.waveform.wfWinKeep = 0.00128;        % half width in seconds

disp('User preferences loaded successfully')

end
