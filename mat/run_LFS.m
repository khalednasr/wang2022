%% LFS, 10Hz
simulation.fieldname = 'LFS';
simulation.wavefunction = @TACS_wave;

E_field.E1.freq = 10e-3;        % 10 Hz
E_field.E2.freq = 0;
E_field.ratio = 0;
E_field.TH_freq = E_field.E1.freq;
E_field.AM_freq = 0;
E_field.phase_diff = 0;

E_field.wvf_type = sprintf('LFS_%g', E_field.E1.freq/1e-3);

if strcmp(simulation.sim_type,'thresh')
    E_field.E1.amp = 32;                % Initial amplitude of E1, V/m
    E_field.scale = sqrt(2);
elseif strcmp(simulation.sim_type,'block')
    E_field.E1.amp = NaN; 
    E_field.scale = sqrt(2);
end

run_1D_stim;
