%% AM-HFS, 2kHz
simulation.fieldname = 'AM_HFS';
simulation.wavefunction = @TACS_wave;

E_field.E1.freq = 2;        % 2 kHz
E_field.E2.freq = 0;
E_field.ratio = 0;
E_field.TH_freq = 10e-3;    % 10 Hz
E_field.AM_freq = 10e-3;    % 10 Hz
E_field.phase_diff = 0;

E_field.wvf_type = sprintf('AM_HFS_%g_%gk', E_field.AM_freq/1e-3, E_field.E1.freq);

if strcmp(simulation.sim_type,'thresh')
    E_field.E1.amp = 128;               % Initial amplitude of E1, V/m
    E_field.scale = sqrt(2);
elseif strcmp(simulation.sim_type,'block')
    E_field.E1.amp = 3000;      % Initial amplitude of E1, V/m
    E_field.scale = sqrt(2);
end

run_1D_stim;
