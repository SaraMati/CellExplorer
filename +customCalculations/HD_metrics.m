function cell_metrics = HD_metrics(cell_metrics,session,spikes,parameters)
    % This is an example template for creating your own calculations
    %
    % INPUTS
    % cell_metrics - cell_metrics struct
    % session - session struct with session-level metadata
    % spikes_intervalsExcluded - spikes struct filtered by (manipulation) intervals
    % spikes - spikes cell struct
    %   spikes{1} : all spikes
    %   spikes{2} : spikes excluding manipulation intervals
    % parameters - input parameters to ProcessCellExplorer
    %
    % OUTPUT
    % cell_metrics - updated cell_metrics struct
    basepath = session.general.basePath; 
    load (fullfile(basepath,'\Analysis\HDinfo.mat'),'hdInfo');
    cell_metrics.hdInfo = hdInfo';
    
    
    load (fullfile(basepath,'\Analysis\CellDepth.mat'),'cellDep');
    cell_metrics.cellDepth = cellDep';

    load (fullfile(basepath,'\Analysis\Layers.mat'),'l');
    cell_metrics.layers = l';
end