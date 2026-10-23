% Opens tvec.txt, ap_times_all.txt,ap_netids_all.txt,vm_matrix.txt,
% secnames.txt, and threshE_angle.txt
% Reads vm vs. t vector for each section as vector in 1 x numSect cell
% array - vm_matrix
% Now reads ap times of every section in a single vector and corresponding
% netids in a second vector
% used for thresh loop and pol loop, if latter, deltaVm is output as
% 'threshE'    
function data = save_data(mat_data_folder, simulation, E_field)    

time_file = fullfile(mat_data_folder,'tvec.txt');  % time vector (tvec)
vm_bin_file = fullfile(mat_data_folder,'vm_data_bin.txt'); % membrane potentials at each time point

all_ap_file = fullfile(mat_data_folder,'all_ap_times.txt'); % ap times in all sections (ap_times)
all_netids_file = fullfile(mat_data_folder,'all_ap_netids.txt'); % net id of each event in ap_file (ap_netids)

thresh_cmprt_ap_file = fullfile(mat_data_folder,'thresh_cmprt_ap_times.txt'); % ap times in all sections (ap_times)
thresh_cmprt_netids_file = fullfile(mat_data_folder,'thresh_cmprt_ap_netids.txt'); % net id of each event in ap_file (ap_netids)

file_name = fullfile(mat_data_folder,sprintf('%s.txt',simulation.sim_type));

% Read time vector
tvec = nrn_vread(simulation, time_file); % Read binary time vector

% open membrane potential over time for each section
vmraw = nrn_vread(simulation, vm_bin_file);
num_timepoints = vmraw(1);
num_sections = vmraw(2);
% all arrays but first have extraneous number at beginning
% first array has num_timepoints and num_sections, remove all numbers
vmraw = vmraw(3:end);
%vmraw(abs(vmraw)<=1e-20) = [];
vmraw(num_timepoints+1 : num_timepoints+1 : (num_timepoints+1)*(num_sections-1) ) = []; % remove 8.48e-314 junk
vmraw = reshape(vmraw, num_timepoints, num_sections);
if ( length(tvec) == size(vmraw,1) )
    vm_matrix = mat2cell(vmraw, num_timepoints, ones(1,num_sections));
%     vm_matrix = cellfun(@(x) assign1(x, x(2)), vm_matrix, 'UniformOutput', false); % set first value to first point
elseif ( length(tvec) == (size(vmraw,1)-1) ) % in case (on cluster) vm vectors have extra element
    vmraw = vmraw(2:end,:); % remove first duplicate value
    vm_matrix = mat2cell(vmraw, num_timepoints-1, ones(1,num_sections));
else
    error('Mismatch between Vm time points and tvec time points');
end
fprintf(simulation.fid,'Read %g Vm time points from %g sections.\n', num_timepoints, num_sections);


% Read ap_times vector
all_ap_times = nrn_vread(simulation,all_ap_file); % Read binary spike time data
all_ap_times(all_ap_times<1e-5) = []; % if no spikes, leave empty
all_ap_times = all_ap_times'; % Change to row vector

% Read netids vector
all_ap_netids = nrn_vread(simulation,all_netids_file);
all_ap_netids(all_ap_netids<1e-5) = []; % same as above
all_ap_netids = all_ap_netids'; %change to row vector to match ap_times

% Read ap_times vector
thresh_cmprt_ap_times = nrn_vread(simulation,thresh_cmprt_ap_file); % Read binary spike time data
thresh_cmprt_ap_times(thresh_cmprt_ap_times<1e-5) = []; % if no spikes, leave empty
thresh_cmprt_ap_times = thresh_cmprt_ap_times'; % Change to row vector

% Read netids vector
thresh_cmprt_ap_netids = nrn_vread(simulation,thresh_cmprt_netids_file);
thresh_cmprt_ap_netids(thresh_cmprt_ap_netids<1e-5) = []; % same as above
thresh_cmprt_ap_netids = thresh_cmprt_ap_netids'; %change to row vector to match ap_times

all_ap_times = [all_ap_times, thresh_cmprt_ap_times];
all_ap_netids = [all_ap_netids, thresh_cmprt_ap_netids];
[all_ap_times, ind]= sort(all_ap_times);
all_ap_netids = all_ap_netids(ind);


% % save to .mat files
% % params = struct('simulation',simulation,'E_field',E_field);
% % save(fullfile(mat_data_folder,'params.mat'),'params');
% % save(fullfile(mat_data_folder,'E_field.mat'),'E_stim');
% 
save(fullfile(mat_data_folder,'Vm.mat'),'tvec','vm_matrix');
save(fullfile(mat_data_folder,'APtimes.mat'),'all_ap_times','all_ap_netids');
% 
% firing_str = struct('num_spikes',[],'spikes',[],'num_bursts',[],'bursts',[]);
% data = struct('th_amp_sum',cell([4,4,2]),'th_vec_sum',cell([4,4,2]),'soma', firing_str ,'axon', firing_str );
% data = struct('th_amp_sum', 0, 'th_vec_sum', 0, 'ap_times', [], 'ap_ids', []);

% E1_x = E1 * cosd(E_field.E1.phi) * sind(E_field.E1.theta);
% E1_y = E1 * sind(E_field.E1.phi) * sind(E_field.E1.theta);
% E1_z = E1 * cosd(E_field.E1.theta);
% E2_x = E2 * cosd(E_field.E2.phi) * sind(E_field.E2.theta);
% E2_y = E2 * sind(E_field.E2.phi) * sind(E_field.E2.theta);
% E2_z = E2 * cosd(E_field.E2.theta);
% E_vec_sum = sqrt( (E1_x+E2_x)^2 + (E1_y+E2_y)^2 + (E1_z+E2_z)^2 );
% 
% data.th_amp_sum = E_amp_sum;
% data.th_vec_sum = E_vec_sum;
data.soma.num_spikes = sum(all_ap_netids == 1);
data.soma.spikes = all_ap_times(all_ap_netids == 1);

[data.soma.num_bursts, data.soma.bursts, data.soma.burst_spike_count] = analyze_spike_time(data.soma.spikes, simulation, E_field);

data.axon.num_spikes = sum(all_ap_netids == 2);
data.axon.spikes = all_ap_times(all_ap_netids == 2);
[data.axon.num_bursts, data.axon.bursts, data.axon.burst_spike_count] = analyze_spike_time(data.axon.spikes, simulation, E_field);

% Read Threshold
fid = fopen(file_name,'r');
if fid < 0
    data.E1_amp = E_field.E1.amp;
else
    thresh_data = fscanf(fid,'%f');
    fclose(fid);
    E1 = thresh_data(1);
    data.E1_amp = E1;
    % if E_field.E2.ratio~=0
    %     E2 = E1 / E_field.E2.ratio;
    % else
    %     E2 = 0;
    % end
    % E_amp_sum = E1 + E2;
    ap.firing_rate = thresh_data(2);
    ap.burst_spike_mean = thresh_data(3);
    ap.num_bursts = thresh_data(4);
    if ap.num_bursts > 0
        ap.burst_spike_count = [thresh_data(5:end)];
    else
        ap.burst_spike_count = [];
    end
    fprintf(simulation.fid,'\tE1 thresh amp: %.2f. Firing rate: %.2f Hz.\n\tNumber of bursts: %d. Mean number of spike per burst: %.2f. \n', E1, ap.firing_rate, ap.num_bursts, ap.burst_spike_mean);
    save(fullfile(mat_data_folder,'APtimes.mat'),'ap','-append');
end
   

% block_file = fullfile(mat_data_folder,sprintf('block.txt'));
% 
% fid = fopen(block_file,'r');
% block_data = fscanf(fid,'%f');
% fclose(fid);
% E1 = block_data(1);
% E2 = E1 * E_field.E2.ratio;
% E_amp_sum = E1 + E2;
% ap.firing_rate = block_data(2);
% ap.burst_spike_mean = block_data(3);
% ap.num_bursts = block_data(4);
% if ap.num_bursts > 0
%     ap.burst_spike_count = [block_data(5:end)];
% else
%     ap.burst_spike_count = [];
% end
% fprintf(simulation.fid,'\tTotal block E: %.2f. Firing rate: %.2f Hz.\n', E_amp_sum, ap.firing_rate);
% E1_x = E1 * cosd(E_field.E1.phi) * sind(E_field.E1.theta);
% E1_y = E1 * sind(E_field.E1.phi) * sind(E_field.E1.theta);
% E1_z = E1 * cosd(E_field.E1.theta);
% E2_x = E2 * cosd(E_field.E2.phi) * sind(E_field.E2.theta);
% E2_y = E2 * sind(E_field.E2.phi) * sind(E_field.E2.theta);
% E2_z = E2 * cosd(E_field.E2.theta);
% E_vec_sum = sqrt( (E1_x+E2_x)^2 + (E1_y+E2_y)^2 + (E1_z+E2_z)^2 );
% data.bl_amp_sum = E_amp_sum;
% data.bl_vec_sum = E_vec_sum; 

save(fullfile(mat_data_folder,'data.mat'),'data');

fprintf(simulation.fid,'\tSaved data to %s.\n',mat_data_folder);

% % % 
% % Check data
% fprintf(simulation.fid,'Checking whether NEURON burst analysis is same as MATLAB.\n');
% if simulation.cmprt == 1
%     test_cmprt = data.soma;
% elseif simulation.cmprt == 2
%     test_cmprt = data.axon;
% end
% fprintf(simulation.fid,'Checking %s.\n',simulation.cmprt_str);
% 
% fprintf(simulation.fid,'Number of burst is ');
% flag_num_burst = (ap.num_bursts == test_cmprt.num_burst);
% if flag_num_burst
%     fprintf(simulation.fid,'correct: %g\n', ap.num_bursts);
%     for ii = 1 : ap.num_bursts
%         fprintf(simulation.fid,'\tNumber of spikes for burst No. %d ', ii);
%         flag_burst_spike_count = (ap.burst_spike_count(ii) == test_cmprt.burst_spike_count(ii));
%         if flag_burst_spike_count
%             fprintf(simulation.fid,'correct: %g\n', ap.burst_spike_count(ii));
%         else
%             fprintf(simulation.fid,'incorrect. NEURON: %g. MATLAB: %g.\n', ap.burst_spike_count(ii), test_cmprt.burst_spike_count(ii));
%         end
%     end
%     fprintf(simulation.fid,'\tAverage number of spikes per burst is ');
%     flag_burst_spike_mean = (abs((ap.burst_spike_mean - mean( test_cmprt.burst_spike_count))) < 1e-6);
%     if flag_burst_spike_mean
%         fprintf(simulation.fid,'correct: %g\n', ap.burst_spike_mean);
%     else
%         fprintf(simulation.fid,'incorrect. NEURON: %g. MATLAB: %g.\n', ap.burst_spike_mean,  test_cmprt.burst_spike_count);
%     end
% else
%     fprintf(simulation.fid,'incorrect. NEURON: %g. MATLAB: %g.\n', ap.num_bursts, test_cmprt.num_burst);
% end
% % % 

% delete(time_file);
% delete(vm_bin_file);
% delete(all_ap_file);
% delete(all_netids_file);
% delete(thresh_cmprt_ap_file);
% delete(thresh_cmprt_netids_file);
% delete(file_name);
% delete(block_file);
% fprintf(simulation.fid,'\tDeleted raw data text files.\n');
end


function x = assign1(x,v)
    x(1) = v;
end

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
