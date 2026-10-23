% Creates directory for data storage of given run in Data/ of current
% directory
% Used for MATLAB and NEURON data folders, assumes model directory is in a
% folder called NEURON
% MATLAB data organization
    % matlab_direc -> Data -> cell_name -> model_prefix -> model_name ->
    % .mat files
% NEW NEURON parallelized data organization
    % nrn_direc -> tmp -> tmp_<cell_name>_<model_name> -> current .txt files

function [nrn_run_name, run_tmp_folder, run_params_fold] = create_nrn_folder(nrn_direc, simulation)    

sim_name = simulation.sim_name;    % simulation name for name of tmp folder and MATLAB data folder
cell_name = simulation.cell_model_name;
run_name = simulation.run_name;
fid = simulation.fid;   

nrn_run_name = sprintf('%s_%s_%s', sim_name, cell_name, run_name);

% Create general tmp directory if necessary
tmp_folder = fullfile(nrn_direc, 'tmp');
if exist(tmp_folder,'dir') == 0
    mkdir(tmp_folder);
end

% Create general Params directory if necessary
params_folder = fullfile(nrn_direc,'Params');
if exist(params_folder,'dir') == 0
    mkdir(params_folder);
end

% Create current simulation's specific tmp directory in the general tmp
run_tmp_folder = fullfile(tmp_folder, nrn_run_name);
if exist(run_tmp_folder,'dir') == 0
    fprintf(fid, 'Created run tmp directory in %s.\n', tmp_folder);
else
    rmdir(run_tmp_folder, 's');
    fprintf(fid, 'Overwriting previous run data in %s.\n', run_tmp_folder);
end
mkdir(run_tmp_folder);
    
% Create current simulation's specific Params directory in the
% general Params folder
run_params_fold = fullfile(params_folder, nrn_run_name);
if exist(run_params_fold,'dir') == 0
    fprintf(fid, 'Created run Params directory in %s.\n', params_folder);
else
    rmdir(run_params_fold,'s');
    fprintf(fid, 'Overwriting previous run Params data in %s.\n', run_params_fold);
end
mkdir(run_params_fold);


end
