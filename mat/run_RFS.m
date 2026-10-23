%% RFS, 2 kHz + 2 kHz
simulation.fieldname = 'RFS';
simulation.wavefunction = @TACS_wave;

E_field.E1.freq = 2;        % 2 kHz
E_field.E2.freq = 2;        % 2 kHz
E_field.TH_freq = 10e-3;    % 10 Hz
E_field.AM_freq = 0e-3;     % 0 Hz, NO AM
E_field.phase_diff = pi/2;

E_field.wvf_type = sprintf('RFS_%gk%', E_field.E1.freq);

run_3D_stim;
