function [simulation, E_field, I_inj] = load_params(cell_id, orientation_id) % load parameter structures
% Create simulation and E_field data structures

%% Simulation
% Define simulation name
simulation.sim_name = 'TIS_threshold';          	% Thresholds under given E-field set-up; the general name of model, name of folder with all model runs
simulation.sim_type = 'threshold';                  % Name of model type, e.g. "threshold" or "current injection" or "block" etc.


simulation.dt = 0.025;                              % Default is 50 us, in ms. For cluster, set to 25 us.
simulation.record_dt = 0.050;                       % Recording is at same time steps.
simulation.t_stop = 4000;                           % 4 s in ms. Total simulation time 

% % simulation.synapses_on = 0;                     % 1 - synaptic inputs on, 2 synaptic inputs off
% % simulation.load_potentials = 0;                 % 0 - use theta,phi to calculate potentials in NEURON
% % simulation.resave = 0;                          % 1 - save new coordinates.txt file, 2 - don't save new file, reuse existing coordinates#.txt file


% Simulation parameters for neuron
% Define cell type
simulation.cell_model_id = cell_id;                         % Cell id
simulation.cell_model_name = cellmodelnames(cell_id);       % Input cell_model_name string
fprintf('\tCell model name: %s.\n', simulation.cell_model_name);
simulation.temp = 37;                               % degree C.
simulation.ss_init = 1;                             % 1 - initialize to steady state, 0 - just use v_init
simulation.v_init = default_v_inits(cell_id);       % mV, only matters if ss_init = 0

nrn_model_ver = 'M_A_my';       % mice adult myelinated 
simulation = output_morph_params(nrn_model_ver, simulation);
if (simulation.prune_axon >=1 && simulation.replace_axon == 1)
    error('Cannot prune axon when replacing with axon with initial segment.\n');	% Ensures conflict is not reached in NEURON
end
if simulation.cell_model_name(2) == '5' || simulation.cell_model_name(2) == '6'
    simulation.modify_axon = 1;                         % If 1, modify main axon terminal
else 
    simulation.modify_axon = 0;
end
simulation.scale_mainaxon_diam = 1;                 % If !=1, scale all main axonal comp diameters by this factor

%% I_inj
I_inj.st_amp = 0;           % nA - amplitude of current injection in soma for tonic firing
I_inj.st_del = 0;           % ms - delay
I_inj.st_dur = 0;           % ms - current injection stimulus duration
I_inj.st_mode = 1;          % 1 - Constant DC, 2 - Custom waveform saved as vector

%% E-field
E_field.E1.t_up = 500;              % Default 500 ms ramp-up
E_field.E1.t_down = 250;            % Default 250 ms ramp-down
E_field.E1.t_delay = 0;             % Default 000 ms delay
E_field.E2.t_up = 500;              % Default 500 ms ramp-up
E_field.E2.t_down = 250;            % Default 250 ms ramp-down
E_field.E2.t_delay = 0;             % Default 000 ms delay

E_field.E1.freq = 2;                % Default 2 kz, in kHz
E_field.E2.freq = 2.01;             % Default 2.10 kHz, in kHz
E_field.wvf_type = 'TIS';           % 'LFS' for low frequency, 'TIF' for interfering field, 'HFS' for carrier only
E_field.E1.amp = 50;                % Default field amplitude of E1, in V/m
E_field.ratio = 1;                  % Ratio of E1 vs. E2. Default 1 (same field strength). >1: E1 larger; <1: E2 larger. 0, no E2.
E_field.phase_diff = 0;             % Phase difference is 0 rad
%%
orientation_case = 0; % fix to 16 orientations
[ THETA, PHI, ~ ] = Efield_orientation(orientation_case);


E_field.E1.theta = THETA(orientation_id);
E_field.E1.phi   = PHI(orientation_id);

fprintf('\tOrientation of E1: ID = %d, theta = %1.1f, phi = %1.1f.\n', orientation_id, E_field.E1.theta, E_field.E1.phi);

E_field.E2.theta = 0;
E_field.E2.phi   = 0;

orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f',E_field.E1.theta, E_field.E1.phi);

simulation.orientation_id = orientation_id;
simulation.orientation_name = orientation_name;

end
