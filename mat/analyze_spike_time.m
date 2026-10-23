function [burst_count, burst_times, burst_spike_count] = analyze_spike_time(spike_times, simulation, E_field)

burst_ISI = 15;     % ms
burst_total = 50;   % ms

burst_count = 0;
burst_times = [];
burst_spike_count = [];


ind_valid_spike1 = find(spike_times >= E_field.t_ss_start,1);
ind_valid_spike2 = find(spike_times <= E_field.t_ss_end,1,'last');

if isempty(ind_valid_spike1)
    fprintf(simulation.fid,'\tNo spikes within time window.');
else
    valid_spikes = spike_times(ind_valid_spike1 : ind_valid_spike2);
%     fprintf('Total spikes within time window: %d.\n', length(valid_spikes));
    ii = 1;
    while (ii<= length(valid_spikes))
        first_spike = valid_spikes(ii);
        pre_spike = first_spike;
        burst_count = burst_count + 1;
        burst_times = [burst_times,first_spike];
        in_burst = 1;
        burst_spike_count = [burst_spike_count,1];
%         fprintf('Burst No. %d: first AP at %3.2f ms.\n', burst_count, first_spike)
        ii = ii+1;
        
        while (ii <=length(valid_spikes) && in_burst)
            next_spike = valid_spikes(ii);
            ISI = next_spike - pre_spike;
            if (ISI < burst_ISI && next_spike - first_spike <= burst_total)
                pre_spike = next_spike;
                burst_spike_count(burst_count) =  burst_spike_count(burst_count) + 1;
                ii = ii+1;
            else
                in_burst = 0;
            end
%             fprintf('Spike at %3.2f ms, ISI %3.2f ms. Within burst: %d. Spikes count within burst: %d.\n', next_spike,ISI, in_burst, burst_spike_count(burst_count))
        end
%         fprintf('Total spikes within Burst No. %d: %d.\n', burst_count, burst_spike_count(burst_count));
    end
    fprintf(simulation.fid,'\tTotal bursts %d. Average number of spikes per burst. %.2f.\n', burst_count, mean(burst_spike_count));
end

end
