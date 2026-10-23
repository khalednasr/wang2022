function data =  run_orientation_ratio(simulation, E_field, I_inj, orient_E2, ratio)
run_nrn_fun = simulation.run_nrn_fun;

if strcmp(simulation.sim_type,'thresh') 
    E_field.E1.amp = 128 ;            % Initial amplitude of E1, V/m
elseif strcmp(simulation.sim_type,'block')
    E_field.E1.amp = 3000 ;           % Initial amplitude of E1, V/m
end
E_field.scale = sqrt(2);

orientation_case = 0; % fix to 16 orientations
[ THETA, PHI] = Efield_orientation(orientation_case);

E_field.E2.theta = THETA(orient_E2);
E_field.E2.phi   = PHI(orient_E2);
fprintf('\tOrientation of E2: ID = %d, theta = %1.1f, phi = %1.1f.', orient_E2, E_field.E2.theta, E_field.E2.phi);

E_field.ratio = ratio;
fprintf('\tRatio of E2: 1/%d.\n', E_field.ratio);

wave_fun = simulation.wavefunction;
field_name = simulation.fieldname;

[  simulation.t_vec, E_field.E1.vec, E_field.E2.vec, ...
    E_field.min_spike_num, E_field.t_ss_start, E_field.t_ss_end] = wave_fun(simulation, E_field, 0);
fprintf('\tType: %s.\tCreated waveform and related parameters.\n', E_field.wvf_type);

orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f_theta2_%1.1f_phi2_%1.1f',...
                    E_field.E1.theta, E_field.E1.phi,E_field.E2.theta, E_field.E2.phi);

simulation.orientation_name = orientation_name;
run_name = sprintf( '%s_ratio_%g_%s_%s',simulation.orientation_name, E_field.ratio, simulation.cmprt_str, E_field.wvf_type);
simulation.run_name = run_name;

data.(field_name) = run_nrn_fun(simulation, E_field, I_inj);

fprintf('---------------------------------------------------------------------\n');
first_th = data.(field_name).E1_amp;

E_field.E1.amp = first_th*0.97;
E_field.scale = 2^(1/2^4);

fprintf('\tOrientation of E2: ID = %d. Running threshold for reversed E2 orientation.\n', orient_E2);
E_field.E2 = revert_field(E_field.E2);
orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f_theta2_%1.1f_phi2_%1.1f',...
                    E_field.E1.theta, E_field.E1.phi,E_field.E2.theta, E_field.E2.phi);
simulation.orientation_name = orientation_name;
run_name = sprintf( '%s_ratio_%g_%s_%s',simulation.orientation_name, E_field.ratio, simulation.cmprt_str, E_field.wvf_type);
simulation.run_name = run_name;

data.(sprintf('%s_revert2',field_name)) = run_nrn_fun(simulation, E_field, I_inj);

fprintf('---------------------------------------------------------------------\n');
fprintf('\tOrientation of E2: ID = %d. Running threshold for reversed E1 and E2 orientations.\n', orient_E2);
E_field.E1 = revert_field(E_field.E1);
orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f_theta2_%1.1f_phi2_%1.1f',...
                    E_field.E1.theta, E_field.E1.phi,E_field.E2.theta, E_field.E2.phi);
simulation.orientation_name = orientation_name;
run_name = sprintf( '%s_ratio_%g_%s_%s',simulation.orientation_name, E_field.ratio, simulation.cmprt_str, E_field.wvf_type);
simulation.run_name = run_name;

data.(sprintf('%s_revert12',field_name)) = run_nrn_fun(simulation, E_field, I_inj);

fprintf('---------------------------------------------------------------------\n');
fprintf('\tOrientation of E2: ID = %d. Running threshold for reversed E1 orientation.\n', orient_E2);
E_field.E2 = revert_field(E_field.E2);
orientation_name = sprintf( 'theta1_%1.1f_phi1_%1.1f_theta2_%1.1f_phi2_%1.1f',...
                    E_field.E1.theta, E_field.E1.phi,E_field.E2.theta, E_field.E2.phi);
simulation.orientation_name = orientation_name;
run_name = sprintf( '%s_ratio_%g_%s_%s',simulation.orientation_name, E_field.ratio, simulation.cmprt_str, E_field.wvf_type);
simulation.run_name = run_name;

data.(sprintf('%s_revert1',field_name)) = run_nrn_fun(simulation, E_field, I_inj);
end
