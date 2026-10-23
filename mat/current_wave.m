% Takes current_inj as input, 
function [t_vec, I_vec] = current_wave(simulation, I_inj, plot_wave)

dt = simulation.dt;
t_start = 0;     % ms
t_stop = simulation.t_stop;

t_stop =  floor( t_stop / dt) * dt;         % Simulation end time
t_vec = ( t_start : dt : t_stop )';

del = I_inj.st_del;
dur = I_inj.st_dur;
amp = I_inj.st_amp;

pulse_dur = I_inj.pulse_dur; 
rep_rate = I_inj.rep_rate*1e-3; % (1/s) * 1e-3 s/ms -> (1/ms)
pulse_type = I_inj.pulse_type; 

if strcmp(pulse_type,'square')
    rep = floor(((0:1/rep_rate:dur) + del + pulse_dur/2)/dt)*dt;
    I_vec = amp * pulstran(t_vec, rep, @rectpuls, pulse_dur);
elseif strcmp(pulse_type,'ramp')
    rep = floor(((0:1/rep_rate:dur) + del + pulse_dur/2)/dt)*dt;
    I_vec = amp * pulstran(t_vec, rep, @tripuls, pulse_dur, 1);
end
if plot_wave
    figure;
    set(gcf,'Color','w');
    plot(t_vec, I_vec);
    xlabel('time (ms)'); 
    ylabel('Current (nA)');
    title('Current injection waveform (mode=2)');
end

end
