if ~isnan(E_field.E1.amp)
    run_nrn_fun= simulation.run_nrn_fun;
    wave_fun = simulation.wavefunction;

    fprintf('=====================================================================\n');
    fprintf('=====================================================================\n');
    t_Type_start = tic;

    fprintf('Stimulation type: %s.\n', E_field.wvf_type);

    [  simulation.t_vec, E_field.E1.vec, E_field.E2.vec, ...
        E_field.min_spike_num, E_field.t_ss_start, E_field.t_ss_end] = wave_fun(simulation, E_field, false);
    fprintf('\tType: %s. \tCreated waveform and related parameters.\n', E_field.wvf_type);

    orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f', E_field.E1.theta, E_field.E1.phi);
    simulation.orientation_name = orientation_name;
    run_name = sprintf( '%s_%s_%s',simulation.orientation_name, simulation.cmprt_str, E_field.wvf_type);
    simulation.run_name = run_name;

    results.(simulation.fieldname) = run_nrn_fun(simulation, E_field, I_inj);

    fprintf('---------------------------------------------------------------------\n');
    fprintf('\tRunning threshold for reversed E1 orientation.\n');
    E_field.E1 = revert_field(E_field.E1);

    E_field.E1.amp = results.(simulation.fieldname).E1_amp*0.97;
    E_field.scale = 2^(1/2^4);

    orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f', E_field.E1.theta, E_field.E1.phi);
    simulation.orientation_name = orientation_name;
    run_name = sprintf( '%s_%s_%s',simulation.orientation_name, simulation.cmprt_str, E_field.wvf_type);
    simulation.run_name = run_name;

    results.(sprintf('%s_revert',simulation.fieldname)) = run_nrn_fun(simulation, E_field, I_inj);

    E_field.E1 = revert_field(E_field.E1);
    fprintf('---------------------------------------------------------------------\n');

    T_type = toc(t_Type_start);
    T_h = floor(T_type/3600);
    T_m = floor((T_type - T_h*3600)/60);
    T_s = T_type - T_h * 3600 - T_m * 60;
    time_str = sprintf('Total time: %d:%d:%2.2f.', T_h, T_m, T_s);
    fprintf('\tFinished. %s\n\n', time_str);

end
