function main_func_3D_RFS(cell_id, orientation_id, sim_type)
%% cell_id
% 01-05: L2/3 continuous adapting pyramidal cell                        **
% 06-10: L5 untufted continuous adapting pyramidal cell             *
% 11-15: L4 continuous accomodating Large Basket Cell
% 16-20: L5 continuous adapting thick tufted pyramidal cell, early bifurcating apical tuft   **
% 21-25: L4 continuous adapting pyramidal cell
% 26-30: L1 burst-non accomodating Neurogliaform cell w/ dense axonal arbor
% 31-35: L1 continuous non-accomodating Large Axon Cell
% 36-40: L6 Tufted Pyramidal Cell with dendritic tuft in layer 4
% 41-45: L5 Slender-tufted pyramidal cell                           *
% 46-50: L5 Thick Tufted Pyramidal cell, late bifurcating tuft      *
% 51-55: L1 continuous non-accomodating NGC w/ dense axon
%
% node0_all = [908, 741, 883, 626, 754];
% term_all = [1600, 1289, 1573, 1059, 1315];

% orientation_id: 1-16

cmprt_id = 1;
cmprt_str = {'soma','term','AIS','node0'};
% type_str = {'TIS_diff','TIS_carr'};

%%
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
fprintf('Running a simulation JOB for TIS with Blue Brain NEURON model.\n');
fprintf('Cell ID %d. Orientation ID of E-field 1: %d. \n', cell_id, orientation_id);
fprintf('%s for firing at %s (%d).\n', sim_type, cmprt_str{cmprt_id}, cmprt_id);


%% Load basic and default model information
matlab_direc = pwd;                % add path for functions

fprintf('Set up parameters.\n')
[simulation, E_field, I_inj] = load_params(cell_id, orientation_id); % load parameter structures

simulation.cmprt = cmprt_id;   % soma
simulation.cmprt_str = cmprt_str{simulation.cmprt};


if ispc
    simulation.if_parfor = 0;
    simulation.fid = 1;
elseif isunix % Set up parpool
    pause( randi( [100,600],1 ) / 10 );
    
    numCPUs = str2double(getenv('SLURM_CPUS_PER_TASK'));
    fprintf('\nSetting up cluster pool.\nNumber of CPUs requested = %d.\n', numCPUs);
    
    pc_storage_dir = fullfile('..','PC_storage',getenv('SLURM_JOB_ID'));    % assign JobStorageLocation based on id of SLURM job that called this function   
    mkdir(pc_storage_dir);

    pc = parcluster('local');
    pc.JobStorageLocation =  pc_storage_dir;
    poolobj = parpool(pc, numCPUs-1);
    
    simulation.if_parfor = 1;
    simulation.fid = [];
    simulation.dt = 0.010;                  % 10 us, in ms. smaller step on cluster
    simulation.record_dt = 0.020;        	% Recording is at larger time steps.
    fprintf('Time step set to: %1.1f us. Recording time step set to %1.1f.\n',simulation.dt*1000, simulation.record_dt * 1000);
end

%%
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');

fprintf('%s.\n',sim_type);
simulation.sim_type = sim_type;         % Name of model type, e.g. "threshold" or "current injection" or "block" etc.
simulation.sim_name = simulation.sim_type;

if strcmp(simulation.sim_type,'thresh') 
    simulation.run_nrn_fun = @run_nrn_thresh;
elseif strcmp(simulation.sim_type,'block')
    simulation.run_nrn_fun = @run_nrn_block;
    E_field.E1.t_delay = 250;
    E_field.E2.t_delay = 250;
end


filename = fullfile(matlab_direc, '..', 'Data', ...
    simulation.sim_name, simulation.cell_model_name, sprintf( '%s_%s.mat', simulation.orientation_name, simulation.cmprt_str));


%% 2D stim
orientation_case = 0; % fix to 16 orientations
[ ~, ~, num_orient] = Efield_orientation(orientation_case);
ratio = [1,2,4];

run_RFS;

%%

fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
fprintf('=====================================================================\n\n');

if exist('poolobj','var')
    delete(poolobj);
    rmdir(pc_storage_dir, 's'); % delete parfor temporary files
end

% Add "quit;" outside in slurm
end
