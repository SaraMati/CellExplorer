% % % % % % % % % % % % % % % 
% Behavior pipeline tutorial
% Part of CellExplorer
% % % % % % % % % % % % % % % 

% Below is example code for generating the behavioral structs, firing rate maps and show them in CellExplorer

% The necessary steps are:
% 0. Get session info and spikes 
% 1. Import behavior data into CellExplorer/Buzcode data container/format
% 2. Get TTL pulses/global time
% 3. Define behavior struct with limits/boundaries/trials. Two examples
%   3.1: Linear track
%   3.1: Theta maze
% 4. Generate the firing rate maps
% 5. Run CellExplorer Processing pipeline

%% 0. Load session info and spikes
basepath = pwd;
session = loadSession(basepath); % Loading session info

% Loading spikes struct
spikes = loadSpikes('session',session);

%% 1. Importing behavioral tracking from optitrack
% first we import the raw behavioral tracking into a Matlab struct:
% the optitrack output contains timestamps (from optitrack) and position data 
%    optitrack.timestamps      timestamps from optitrack
%    optitrack.position.x      x-position
%    optitrack.position.y      y-position
%    optitrack.position.z      z-position
%    optitrack.speed           speed
%    optitrack.sr              samplingrate

optitrack = optitrack2buzcode('session',session);

% After this you can load the generated file:
% optitrack = loadStruct('optitrack','behavior','session',session);

%% 2. Import TTL pulses from Intan used to synchronize the Intan ephys system with optitrack. 
% In this case, Intan works as the global clock.
% This will also save a struct with the digital input: basename.intanDig.digitalseries.mat
% The digital timeseries contains timestamps of changes in states
% intanDig.on      cell array with on state-changes channel-wise
% intanDig.off     cell array with off state-changes channel-wise

intanDig = intanDigital2buzcode(session);

% After this you can load the generated file:
% intanDig = loadStruct('intanDig','digitalseries','session',session);

%% 3. Define behavior struct with limits/boundaries/trials 
%% 3.1 Linear track

% Now, we can realign the temporal states and generate the new behavioral data struct 
OptitrackSync = session.inputs.OptitrackSync.channels; % TTL channel recorded by intan

% Extending the original behavioral data
lineartrack = optitrack;

% Defining timestamps via the TTL-pulses from Optitrack recorded with intan
lineartrack.timestamps = intanDig.on{OptitrackSync}(1:numel(circular_track.timestamps));

% changing offset-origin if necessary
lineartrack.offsets = [110,-8,0]; 
lineartrack.position.x = lineartrack.position.x+lineartrack.offsets(1);
lineartrack.position.y = lineartrack.position.y+lineartrack.offsets(2);
lineartrack.position.z = lineartrack.position.z+lineartrack.offsets(3);

% Rotating the positional data if necessary
lineartrack.rotation = +0.5; 
if ~isempty(lineartrack.rotation)
    x = lineartrack.position.x;
    y = lineartrack.position.y;
    X = x*cosd(lineartrack.rotation) - y*sind(lineartrack.rotation);
    Y = x*sind(lineartrack.rotation) + y*cosd(lineartrack.rotation);
    lineartrack.position.x = X;
    lineartrack.position.y = Y;
end
lineartrack.position.linearized = lineartrack.position.x;

% Plotting the result
figure, 
plot(lineartrack.position.x,lineartrack.position.y)

% Getting trials via definition of limits 
% As this is a linear track, we simply use the rotated x-position
lineartrack.limits.linearized = [10,190];
lineartrack.trials = getTrials_lineartrack(lineartrack.position.linearized,lineartrack.limits.start,lineartrack.limits.end);

% Now we can save the struct
saveStruct(lineartrack,'behavior','session',session);

% After this you can load the generated file:
% lineartrack = loadStruct('lineartrack','behavior','session',session);

%% 3.2 Circular track

% Now, we can realign the temporal states and generate the new behavioral data struct 
OptitrackSync = session.inputs.OptitrackSync.channels; % TTL channel recorded by intan

% Extending the original behavioral data
circular_track = optitrack;

% Defining timestamps via the TTL-pulses from Optitrack recorded with intan
circular_track.timestamps = intanDig.on{OptitrackSync}(1:numel(circular_track.timestamps));
circular_track.timestamps = circular_track.timestamps(:)';
% changing offset-origin if necessary
circular_track.offsets = [5,-5,0]; % units of cm
circular_track.position.x = circular_track.position.x+circular_track.offsets(1);
circular_track.position.y = circular_track.position.y+circular_track.offsets(2);
circular_track.position.z = circular_track.position.z+circular_track.offsets(3);

% Rotating the positional data if necessary
circular_track.rotation = []; % degrees
if ~isempty(circular_track.rotation)
    x = circular_track.position.x;
    y = circular_track.position.y;
    circular_track.position.x = x*cosd(circular_track.rotation) - y*sind(circular_track.rotation);
    circular_track.position.y = x*sind(circular_track.rotation) + y*cosd(circular_track.rotation);
end

% Next we define maze parameters:
% These are used for linearization and defining states on the maze (e.g. left/right)
maze.type = 'theta';
maze.radius_in = 96.5/2;
maze.radius_out =  116.5/2;
maze.arm_half_width = 4;
maze.cross_radii = 47.9;
maze.polar_rho_limits = [44,65];
maze.polar_theta_limits = [-2.8,2.8]*maze.radius_in;
maze.pos_x_limits = [-10,10]; % -15
maze.pos_y_limits = [-40,45];

maze.boundary{1} = [0,40]; % Central arm y-position boundaries
maze.boundary{2} = [0,25];
maze.boundary{3} = [-15,40]; 
maze.boundary{4} = [15,40];
maze.boundary{5} = [maze.radius_in-3.25,maze.polar_theta_limits(2)];

% Defining trials:
[trials,circular_track] = getTrials_thetamaze(circular_track,maze);

% Circular position
circular_track.states.arm_rim = nan(1,circular_track.nSamples);
circular_track.states.arm_rim(circular_track.position.x > maze.pos_x_limits(1) & circular_track.position.x < maze.pos_x_limits(2) & circular_track.position.y > maze.pos_y_limits(1) & circular_track.position.y < maze.pos_y_limits(2)) = 1;
circular_track.states.arm_rim(circular_track.position.polar_rho > maze.polar_rho_limits(1) & circular_track.position.polar_rho < maze.polar_rho_limits(2) & circular_track.position.polar_theta > maze.polar_theta_limits(1) & circular_track.position.polar_theta < maze.polar_theta_limits(2)) = 2;
circular_track.stateNames.arm_rim = {'arm','rim'};

% Linearizing and defining boundaries
circular_track.position.linearized = linearize_pos_v2(circular_track,maze);
circular_track.limits.linearized = [0,diff(maze.pos_y_limits) + diff(maze.polar_theta_limits)-5];
circular_track.boundaries.linearized = [0,diff(maze.pos_y_limits), diff(maze.pos_y_limits)+ abs(maze.polar_theta_limits(1))-5];
circular_track.boundaryNames.linearized = {'Central arm','Left side','Right side'};

% Setting a minimum speed threshold
circular_track.speed_th = 10;

% Generating left_right states data
circular_track.states.left_right = nan(size(circular_track.trials));
for i = 1:trials.nTrials
    circular_track.states.left_right(circular_track.trials==i) = trials.states.left_right(i);
end
circular_track.stateNames.left_right = {'Left','Right'};

% Saving behavioral data
saveStruct(circular_track,'behavior','session',session);
saveStruct(trials,'behavior','session',session);

% After this you can load the generated files:
% circular_track = loadStruct('circular_track','behavior','session',session);
% trials = loadStruct('trials','behavior','session',session);

%% 4. Generate firingratemaps

% Generating the linearized firing rate map
ratemap = generate_FiringRateMap_1D('spikes',spikes,'behavior',circular_track,'session',session,'x_label','Theta maze position (cm)');

% Generating trial-wise firing rate map
ratemap_Trials = generate_FiringRateMap_1D('spikes',spikes,'behavior',circular_track,'states',circular_track.trials,'dataName','ratemap_Trials','session',session,'x_label','Theta maze position (cm)');

% Generating left-right firing rate map
ratemap_LeftRight = generate_FiringRateMap_1D('spikes',spikes,'behavior',circular_track,'states',circular_track.states.left_right,'stateNames',circular_track.stateNames.left_right,'dataName','ratemap_LeftRight','session',session,'x_label','Theta maze position (cm)');

%% 5. Run CellExplorer's Processing pipeline
% The Processing pipeline will detect and import the firing rate maps, detect place fields and calculate spatial information
%
% The firing rate maps are saved as cell arrays fields, e.g.
% cell_metrics.firingRateMaps.ratemap
%
% Metadata is saved to the .general field, e.g.
% cell_metrics.general.firingRateMaps.ratemap.x_bins
% cell_metrics.general.firingRateMaps.ratemap.boundaries

cell_metrics = ProcessCellMetrics('session',session);

cell_metrics = CellExplorer('metrics',cell_metrics);
