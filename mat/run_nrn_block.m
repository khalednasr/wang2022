function data_comp = run_nrn_block(simulation, E_field, I_inj)

firing_struct = struct('num_spikes',[],'spikes',[],'num_bursts',[],'bursts',[],'burst_spike_count',[]);
data_comp = struct('E1_amp', 0, 'soma', firing_struct, 'axon', firing_struct);
 
matlab_direc = pwd;
fprintf('\tType: %s.\tAdded path.\n', E_field.wvf_type);
% Create data folder in MATLAB directories
mat_data_folder = create_mat_data_folder(matlab_direc, simulation); % make and get matlab data directory
fprintf('\tType: %s.\tCreated Matlab folder.\n', E_field.wvf_type);

% % Check if simulation was already run, skip if yes
% run_data_files = dir(mat_data_folder);              % List of output files
% run_data_files = run_data_files(arrayfun(@(x) ~strcmp(x.name(1),'.'), run_data_files));  % remove '.' hidden files
% run_mat_data_files = run_data_files(arrayfun(@(x) strcmp(x.name(end-3:end),'.mat'), run_data_files)); % Get .mat files
% run_txt_data_files = run_data_files(arrayfun(@(x) strcmp(x.name(end-3:end),'.txt'), run_data_files)); % Get .txt files
% run_txt_data_files = run_data_files(arrayfun(@(x) ~strcmp(x.name(1:3),'log'), run_txt_data_files)); % Remove log .txt files
% 
% num_mat_files = 1;              % 4 output files saved in MATLAB
% num_txt_files = 5;              % 5 output files from NEURON
% 
% if length(run_mat_data_files) >= num_mat_files
%     fprintf('\tType: %s.\t%d .mat files found in %s.\n', E_field.wvf_type ,length(run_mat_data_files), mat_data_folder);
%     load(fullfile(mat_data_folder,'data.mat'),'data');
%     data_comp = data;
% elseif length(run_txt_data_files) >= num_txt_files
%     % %
%     % if length(run_txt_data_files) >= num_txt_files
%     if isempty(simulation.fid)
%         simulation.fid = 1;
%         fid_flag = 1;
%     else
%         fid_flag = 0;
%     end
%     fprintf('\tType: %s.\t%d .txt files found in %s.\n\t\tAnalyzing data.\n', E_field.wvf_type ,length(run_txt_data_files), mat_data_folder);
%     data_comp = save_data(mat_data_folder, simulation, E_field); % saves data to .mat files in MATLAB directory
%     fprintf('\tType: %s.\tData processed.\n\n\n', E_field.wvf_type )
%     if fid_flag
%         simulation.fid = [];
%     end
% end
%     
% if (data_comp.E1_amp)
%     E_field.E1.amp = data_comp.E1_amp;
%     E_field.scale = 2^(1/2^4);
%     fprintf('\tType: %s.\tSkipping current run.\n\n\n', E_field.wvf_type )
% else     
    if  isempty(simulation.fid)

        log_file_name = fullfile(mat_data_folder, 'log.txt');
        %         if exist(log_file_name,'file')
        %             log_id = 1;
        %             log_file_name = fullfile(mat_data_folder, sprintf('log_%d.txt',log_id));
        %             while exist(log_file_name,'file')
        %                 log_id = log_id+1;
        %                 log_file_name = fullfile(mat_data_folder, sprintf('log_%d.txt',log_id));
        %             end
        %         else
        %         end
        %
        fid = fopen(log_file_name,'w');

        if (fid == -1)
            simulation.fid = 1;
            fprintf('\tType: %s.\tWriting to default output.\n', E_field.wvf_type);
        else
            simulation.fid = fid;
            fprintf('\tType: %s.\tWriting to log with id %d.\n', E_field.wvf_type, fid);
        end
    end
    

    %% Run block threshold finder    
    % Create data folder in NEURON directories
    nrn_model_direc = [matlab_direc, filesep, '..', filesep, 'nrn']; % platform agnostic
    [run_name, run_tmp_folder, run_params_folder] = create_nrn_folder(nrn_model_direc, simulation); % make and get neuron data directory

    E_field.t_ss_start = E_field.t_ss_start + 250;
    % E_field.t_ss_end = E_field.t_ss_end - 250;
    % Write model parameters to Params.txt
    Params = [  simulation.cell_model_id; ...
                simulation.replace_axon; ...
                simulation.prune_axon; ...
                simulation.myelinate_axon; ...
                simulation.modify_axon; ...
                simulation.scale_axon_diam; ...
                simulation.scale_mainaxon_diam; ...
                simulation.scale_apic_diam; ...
                simulation.scale_basal_diam; ...
                simulation.scale_soma_area; ...
                simulation.scale_basal_L; ...
                simulation.min_myelin_diam; ...
                simulation.max_myelin_order; ...
                simulation.ss_init; ...
                simulation.v_init; ...
                simulation.temp; ...
                simulation.dt; ...
                simulation.record_dt; ...
                simulation.t_stop; ...
                simulation.cmprt; ...
                E_field.E1.amp * (1 + 0.001 * randn()); ...
                E_field.E1.theta; ...
                E_field.E1.phi; ...
                E_field.E2.theta; ...
                E_field.E2.phi; ...
                E_field.min_spike_num;
                E_field.t_ss_start; ...
                E_field.t_ss_end; ...
                E_field.scale; ...
                I_inj.st_amp; ...
                I_inj.st_del; ...
                I_inj.st_dur; ...
                I_inj.st_mode ...
            ];

    tvec = simulation.t_vec;
    E1_vec = E_field.E1.vec;
    E2_vec = E_field.E2.vec;

    write_vector_bin(run_params_folder, tvec, E1_vec, E2_vec, Params);
    fprintf(simulation.fid,'\nSaved time and E-field vectors and Parameters to model directory for %s.\n', run_name);

    fs = 1/simulation.dt;   % kHz
    % HPS: 0.1 kHz = 100 Hz
    [B_HPF,A_HPF] = butter(3,0.1/(fs/2),'high');
    % BSF: 1 kHz & 15 kHz
    [B_BSF,A_BSF] = butter(5,[1,15]/(fs/2),'stop');
    write_vector_bin(run_params_folder, B_HPF, A_HPF, B_BSF, A_BSF);
    fprintf(simulation.fid,'\nSaved filter parameters directory for %s.\n\n', run_name);

    % NEURON commands
    commands_str = sprintf(' -c "run_name.s=\\"%s"\\" -c "init_run()" -c "find_block_filt()" -c "quit()"', run_name);

    options = sprintf('-nogui -NSTACK %g -NFRAME %g ', 100000, 20000);
    if ispc
        system_call_str = ['C:\nrn\bin\nrniv.exe -nobanner ', options];
        nrn_file = 'init_TIS_stim.hoc';
    elseif isunix
        system_call_str = ['nrniv ', options];
        nrn_file = 'init_TIS_stim_cluster.hoc';
    end

    % %     commands_str = sprintf(' -c "run_name.s=\\"%s"\\" -c "init_run()" -c "color_plot()" -c "topology()" -c "forsec {print secname()}" -c "run_stim()" -c "quit()"', run_name);

    fprintf(simulation.fid, [   'Going to NEURON directory: %s.\n',...
                                'Running NEURON program  %s  followed by commands: \n\t%s\n\n'], nrn_model_direc, nrn_file, commands_str);

    cd(nrn_model_direc);
    t_nrn_start = tic;

    if (simulation.fid == 1)
        system( [system_call_str, nrn_file, commands_str] );
    else
        [~ ,result] = system( [system_call_str, nrn_file, commands_str] );
        fprintf(simulation.fid, 'NEURON output: \n\n\n%s\n\n\n', result);
    end

    T_nrn = toc(t_nrn_start);
    T_h = floor(T_nrn/3600);
    T_m = floor((T_nrn - T_h*3600)/60);
    T_s = T_nrn - T_h * 3600 - T_m * 60;
    time_str = sprintf('%d:%d:%2.2f', T_h, T_m, T_s);

    copyfile(run_tmp_folder, mat_data_folder);       % move contents of tmp folder to permanent folder (NEURON directory)
    rmdir(run_tmp_folder, 's'); % delete old tmp folder
    rmdir(run_params_folder, 's'); % delete current run's params folder
    cd(matlab_direc)

    fprintf(simulation.fid, [	'NEURON simulation time: %s.\n\n',...
        'Contents of tmp folder moved to %s.\n',...
        'Returning to MATLAB directory: %s.\n'], time_str, mat_data_folder, matlab_direc);

    data_comp = save_data(mat_data_folder, simulation, E_field); % saves data to .mat files in MATLAB directory
    fprintf(simulation.fid,'Data processed.\n\n\n');
% end

%% Run block test
%if data_comp.E1_amp <= 6000
    % Create data folder in NEURON directories
    fprintf(simulation.fid, 'Test block!\n');
    nrn_model_direc = [matlab_direc, filesep, '..', filesep, 'nrn']; % platform agnostic
    [run_name, run_tmp_folder, run_params_folder] = create_nrn_folder(nrn_model_direc, simulation); % make and get neuron data directory
%%
    I_inj.st_mode = 2;
    I_inj.st_dur = 4000;        % ms
    I_inj.st_amp = 30;          % nA
    
    I_inj.pulse_dur = 0.100;    % ms
    I_inj.pulse_type = 'square';
    
    I_inj.st_del = 500;         % ms
    I_inj.rep_rate = 5;         % Hz
    [~, I_vec] = current_wave(simulation, I_inj, false);
    % test pulses at 0.5, 1, 1.5, ..., 3.5 s
    
    I_inj.rep_rate = 0.1;       % Hz
    for pp = [50, 200, 3850]           % additional test pulse at 100, 300, and 3850 ms
        I_inj.st_del = pp;         % ms
        [~, I_vec_tmp] = current_wave(simulation, I_inj, false);
        I_vec = I_vec + I_vec_tmp;
    end
    % 0 to 250 ms, baseline; 250 ms to 750 ms, ramp up; 3750 ms to 4000 ms
    % ramp down;
    I_inj.st_del = 0;
    %% 
    % Write model parameters to Params.txt
    Params = [  simulation.cell_model_id; ...
                simulation.replace_axon; ...
                simulation.prune_axon; ...
                simulation.myelinate_axon; ...
                simulation.modify_axon; ...
                simulation.scale_axon_diam; ...
                simulation.scale_mainaxon_diam; ...
                simulation.scale_apic_diam; ...
                simulation.scale_basal_diam; ...
                simulation.scale_soma_area; ...
                simulation.scale_basal_L; ...
                simulation.min_myelin_diam; ...
                simulation.max_myelin_order; ...
                simulation.ss_init; ...
                simulation.v_init; ...
                simulation.temp; ...
                simulation.dt; ...
                simulation.record_dt; ...
                simulation.t_stop; ...
                simulation.cmprt; ...
                data_comp.E1_amp; ...
                E_field.E1.theta; ...
                E_field.E1.phi; ...
                E_field.E2.theta; ...
                E_field.E2.phi; ...
                E_field.min_spike_num;
                E_field.t_ss_start; ...
                E_field.t_ss_end; ...
                E_field.scale; ...
                I_inj.st_amp; ...
                I_inj.st_del; ...
                I_inj.st_dur; ...
                I_inj.st_mode ...
            ];

    tvec = simulation.t_vec;
    E1_vec = E_field.E1.vec;
    E2_vec = E_field.E2.vec;

    write_vector_bin(run_params_folder, tvec, E1_vec, E2_vec, Params, I_vec);
    fprintf(simulation.fid,'\nSaved time, E-field, and current vectors and Parameters to model directory for %s.\n', run_name);

    fs = 1/simulation.dt;   % kHz
    % HPS: 0.1 kHz = 100 Hz
    [B_HPF,A_HPF] = butter(3,0.1/(fs/2),'high');
    % BSF: 1 kHz & 15 kHz
    [B_BSF,A_BSF] = butter(5,[1,15]/(fs/2),'stop');
    write_vector_bin(run_params_folder, B_HPF, A_HPF, B_BSF, A_BSF);
    fprintf(simulation.fid,'\nSaved filter parameters directory for %s.\n\n', run_name);

    % NEURON commands
    commands_str = sprintf(' -c "run_name.s=\\"%s"\\" -c "init_run()" -c "run_block_filt()" -c "quit()"', run_name);

    options = sprintf('-NSTACK %g -NFRAME %g ', 100000, 20000);
    if ispc
        system_call_str = ['C:\nrn\bin\nrniv.exe -nobanner ', options];
        nrn_file = 'init_TIS_stim.hoc';
    elseif isunix
        system_call_str = ['./special ', options];
        nrn_file = 'init_TIS_stim_cluster.hoc';
    end

    % %     commands_str = sprintf(' -c "run_name.s=\\"%s"\\" -c "init_run()" -c "color_plot()" -c "topology()" -c "forsec {print secname()}" -c "run_stim()" -c "quit()"', run_name);

    fprintf(simulation.fid, [   'Going to NEURON directory: %s.\n',...
                                'Running NEURON program  %s  followed by commands: \n\t%s\n\n'], nrn_model_direc, nrn_file, commands_str);

    cd(nrn_model_direc);
    t_nrn_start = tic;

    if (simulation.fid == 1)
        system( [system_call_str, nrn_file, commands_str] );
    else
        [~ ,result] = system( [system_call_str, nrn_file, commands_str] );
        fprintf(simulation.fid, 'NEURON output: \n\n\n%s\n\n\n', result);
    end

    T_nrn = toc(t_nrn_start);
    T_h = floor(T_nrn/3600);
    T_m = floor((T_nrn - T_h*3600)/60);
    T_s = T_nrn - T_h * 3600 - T_m * 60;
    time_str = sprintf('%d:%d:%2.2f', T_h, T_m, T_s);

    mat_data_folder_2 = fullfile(mat_data_folder, 'block_test'); 	% Full path name of data folder, containing either  .mat files
    if exist(mat_data_folder_2,'dir') == 0
        mkdir(mat_data_folder_2)
    end

    copyfile(run_tmp_folder, mat_data_folder_2);       % move contents of tmp folder to permanent folder (NEURON directory)
    rmdir(run_tmp_folder, 's'); % delete old tmp folder
    rmdir(run_params_folder, 's'); % delete current run's params folder
    cd(matlab_direc)

    fprintf(simulation.fid, [	'NEURON simulation time: %s.\n\n',...
                                'Contents of tmp folder moved to %s.\n',...
                                'Returning to MATLAB directory: %s.\n'], time_str, mat_data_folder, matlab_direc);

    save_data(mat_data_folder_2, simulation, E_field); % saves data to .mat files in MATLAB directory
    fprintf(simulation.fid,'Data processed.\n\n\n');

% else
%     mat_data_folder_2 = fullfile(mat_data_folder, 'block_test'); 	% Full path name of data folder, containing either  .mat files
%     if exist(mat_data_folder_2,'dir')
%         rmdir(mat_data_folder_2, 's');
%     end
% end
%%
if (simulation.if_parfor) && (simulation.fid~= 1)
    fclose(simulation.fid);
    simulation.fid = [];
end
end

