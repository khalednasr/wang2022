%% TIS, 2 kHz + 2.01 kHz
simulation.fieldname = 'TIS';
simulation.wavefunction = @TACS_wave;

E_field.E1.freq = 2;        % 2 kHz
E_field.E2.freq = 2.01;     % 2.01 kHz
E_field.TH_freq = 10e-3;    % 10 Hz
E_field.AM_freq = 0;
E_field.phase_diff = 0;

E_field.wvf_type = sprintf('TIS_%g_%gk', abs(E_field.E2.freq-E_field.E1.freq)/1e-3, E_field.E1.freq);

run_3D_stim;
