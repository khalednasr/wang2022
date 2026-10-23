fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
t_Type_start = tic;

fprintf('Stimulation type: %s.\n', E_field.wvf_type);

ratio_data = struct(sprintf('%s',simulation.fieldname),cell([num_orient,3]),...
                    sprintf('%s_revert1',simulation.fieldname),cell([num_orient,3]),...
                    sprintf('%s_revert2',simulation.fieldname),cell([num_orient,3]),...
                    sprintf('%s_revert12',simulation.fieldname),cell([num_orient,3]));

if simulation.if_parfor
    fprintf('Looping through stimulation with "parfor".\n');
    orient_E2 = 1 : num_orient;
    [orient_E2_grid, ratio_grid ] = ndgrid(orient_E2,ratio);
    parfor kk = 1:numel(ratio_grid)        
        ratio_data(kk) = run_orientation_ratio(simulation, E_field, I_inj, orient_E2_grid(kk), ratio_grid(kk));
    end
else
    fprintf('Looping through stimulation types with "for".\n');
    for ind_ratio = 1:3
        for orient_E2 = 1 : num_orient
            ratio_data(orient_E2, ind_ratio) = run_orientation_ratio(simulation, E_field, I_inj, orient_E2, ratio(ind_ratio));
        end
    end
end
results.(simulation.fieldname) = ratio_data;

T_type = toc(t_Type_start);
T_h = floor(T_type/3600);
T_m = floor((T_type - T_h*3600)/60);
T_s = T_type - T_h * 3600 - T_m * 60;
time_str = sprintf('Total time: %d:%d:%2.2f.', T_h, T_m, T_s);
fprintf('\tFinished. %s\n\n', time_str);
fprintf('=====================================================================\n');
fprintf('=====================================================================\n');
