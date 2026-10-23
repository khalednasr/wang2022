% Opens tvec.txt, ap_times_all.txt,ap_netids_all.txt,vm_matrix.txt,
% secnames.txt, and threshE_angle.txt
% Reads vm vs. t vector for each section as vector in 1 x numSect cell
% array - vm_matrix
% Now reads ap times of every section in a single vector and corresponding
% netids in a second vector
% used for thresh loop and pol loop, if latter, deltaVm is output as
% 'threshE'    
function block = save_data_block(mat_data_folder, simulation, E_field)    




% save to .mat files
params = struct('simulation',simulation,'E_field',E_field);

% save(fullfile(mat_data_folder,'params.mat'),'params');
% save(fullfile(mat_data_folder,'Vm.mat'),'tvec','vm_matrix');
% save(fullfile(mat_data_folder,'E_field.mat'),'E_stim');
% save(fullfile(mat_data_folder,'APtimes.mat'),'ap','all_ap_times','all_ap_netids');

% firing_str = struct('num_spikes',[],'spikes',[],'num_bursts',[],'bursts',[]);
% data = struct('th_amp_sum',cell([4,4,2]),'th_vec_sum',cell([4,4,2]),'soma', firing_str ,'axon', firing_str );


E1_x = E1 * cosd(E_field.E1.phi) * sind(E_field.E1.theta);
E1_y = E1 * sind(E_field.E1.phi) * sind(E_field.E1.theta);
E1_z = E1 * cosd(E_field.E1.theta);
E2_x = E2 * cosd(E_field.E2.phi) * sind(E_field.E2.theta);
E2_y = E2 * sind(E_field.E2.phi) * sind(E_field.E2.theta);
E2_z = E2 * cosd(E_field.E2.theta);
Evecsum = sqrt( (E1_x+E2_x)^2 + (E1_y+E2_y)^2 + (E1_z+E2_z)^2 );

block.bl_amp_sum = Eampsum;
block.bl_vec_sum = Evecsum;
block.soma.num_spikes = sum(all_ap_netids == 1);
% block.soma.spikes = all_ap_times(all_ap_netids == 1);
% 
% [block.soma.num_bursts, block.soma.bursts, block.soma.burst_spike_count] = analyze_spike_time(block.soma.spikes, simulation, E_field);
% 
% block.axon.num_spikes = sum(all_ap_netids == 2);
% block.axon.spikes = all_ap_times(all_ap_netids == 2);
% [block.axon.num_bursts, block.axon.bursts, block.axon.burst_spike_count] = analyze_spike_time(block.axon.spikes, simulation, E_field);

save(fullfile(mat_data_folder,'data.mat'),'block','-append');

fprintf(simulation.fid,'Saved DATA to %s.\n',mat_data_folder);

delete(block_file);
fprintf(simulation.fid,'Deleted raw data text files.\n');
end

