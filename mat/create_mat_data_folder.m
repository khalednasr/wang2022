% Creates directory for data storage of given run in Data/ of current
% directory
% Used for MATLAB and NEURON data folders, assumes model directory is in a
% folder called NEURON
% MATLAB data organization
    % matlab_direc -> Data -> cell_name -> model_prefix -> model_name ->
    % .mat files
% NEW NEURON parallelized data organization
    % nrn_direc -> tmp -> tmp_<cell_name>_<model_name> -> current .txt files
    % no Data folder anymore

function mat_data_folder = create_mat_data_folder(mat_direc, simulation)    

sim_name = simulation.sim_name;                     % Simulation name for name of tmp folder and MATLAB data folder
cell_name = simulation.cell_model_name;
run_name = simulation.run_name;

% Make MATLAB data folders
data_direc = fullfile(mat_direc, '..', 'Data');

sim_name_folder = fullfile(data_direc, sim_name);   % Directory containing all results of Run
if exist(sim_name_folder, 'dir') == 0
    mkdir(sim_name_folder);
end

cell_folder = fullfile(sim_name_folder, cell_name);
if exist(cell_folder, 'dir') == 0
    mkdir(cell_folder)
end

mat_data_folder = fullfile(cell_folder, run_name); 	% Full path name of data folder, containing either  .mat files
if exist(mat_data_folder,'dir') == 0
    mkdir(mat_data_folder)
end

end
