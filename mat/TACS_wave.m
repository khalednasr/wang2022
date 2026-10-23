% TACS waveforms
% takes simulation dt and tstop, waveform data structure, and boolean
% plot_wave as inputs. Outputs time and amplitude vector for 2 E-fields
% Boshuo Wang
function [ t_vec, E1_vec, E2_vec, min_spike_num, t_ss_start, t_ss_end] = TACS_wave(simulation, E_field, plot_wave)

dt = simulation.dt;
t_start = 0;     % ms
t_stop = simulation.t_stop;

t_stop =  floor( t_stop / dt) * dt;         % Simulation end time
t_vec = ( t_start : dt : t_stop )';

freq_AM = E_field.AM_freq;
TH_freq = E_field.TH_freq;
phase_diff = E_field.phase_diff;
%%
t_up_1 = E_field.E1.t_up;
t_down_1 = E_field.E1.t_down;
t_delay_1 = E_field.E1.t_delay;
ind_delay_1 = ( t_vec <= t_start + t_delay_1);
ind_ramp_up = ( t_vec <= t_start + t_delay_1 + t_up_1 & t_vec > t_start + t_delay_1);
ind_ramp_down = (t_vec >= (t_stop - t_down_1));
env_ramp = cos(2*pi*freq_AM/2*t_vec);         % cosine to allow no modulation by setting freq_AM to zero, divide by 2 for envelope to have the same frequency
env_ramp(ind_delay_1) = 0;
env_ramp(ind_ramp_up) = env_ramp(ind_ramp_up) .* ( (t_vec(ind_ramp_up) - t_start- t_delay_1) / t_up_1);
env_ramp(ind_ramp_down) = env_ramp(ind_ramp_down) .* (1 - (t_vec(ind_ramp_down) - (t_stop - t_down_1))/t_down_1);

freq_1 = E_field.E1.freq;                     % kHz
E1_vec = sin(2*pi*freq_1*t_vec) .* env_ramp;
%%
t_up_2 = E_field.E2.t_up;
t_down_2 = E_field.E2.t_down;
t_delay_2 = E_field.E2.t_delay;
ind_delay_2 = ( t_vec <= t_start + t_delay_2);
ind_ramp_up = ( t_vec <= t_start + t_delay_2 + t_up_2 & t_vec > t_start + t_delay_2);
ind_ramp_down = (t_vec >= (t_stop - t_down_2));
env_ramp = cos(2*pi*freq_AM/2*t_vec);         % cosine to allow no modulation by setting freq_AM to zero, divide by 2 for envelope to have the same frequency
env_ramp(ind_delay_2) = 0;
env_ramp(ind_ramp_up) = env_ramp(ind_ramp_up) .* ( (t_vec(ind_ramp_up) - t_start - t_delay_2) / t_up_2);
env_ramp(ind_ramp_down) = env_ramp(ind_ramp_down) .* (1 - (t_vec(ind_ramp_down) - (t_stop - t_down_2))/t_down_2);

freq_2 = E_field.E2.freq;     % Hz

if E_field.ratio == 0
    E2_vec = env_ramp * 0;
else
    E2_vec = sin(2*pi*freq_2*t_vec - phase_diff) .* env_ramp  / E_field.ratio;
end
%%
if (E_field.ratio ~= 0) && (E_field.E2.freq ~= 0)
    t_ss_start = max(t_up_2 + t_delay_2, t_up_1 + t_delay_1);
    t_ss_end = t_stop - max(t_down_1,t_down_2);
else
    t_ss_start = t_up_1;
    t_ss_end = t_stop - t_down_1;
end

t_overlap = diff([t_start + t_ss_start, t_ss_end]);

min_spike_num = floor(t_overlap * TH_freq * 0.95);
%%
if plot_wave
    figure;
    set(gcf,'Color','w');
    %plot(tvec_single,single_pulse);
    %plot(tvec(1:round(pulse_per/dt)),single_pulse)
    %plot(tvec_single_train,E_single_train)
    plot(t_vec,E1_vec+2,'b',t_vec,E2_vec +1 ,'r',t_vec,E1_vec+E2_vec-1,'k');
    ylim([-3 3])
    xlabel('time (ms)'); ylabel('Amplitude (V/m)');
%     title(TitleTxt)
end

end
