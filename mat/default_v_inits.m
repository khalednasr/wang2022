% contains default initial voltages (mV) of Mainen and Traub model cells
% February 5th, 2016
% Aman Aberra

function v_init = default_v_inits(cell_id)    

if ~nargin
    cell_id = 0;
end

num_clones = 5;
% Blue Brain cells 1-55
default_v_inits = repelem( [
            -75;    % 01-05: L23_PC_cADpyr229_1
            -75;    % 06-10: L5_UTPC_cADpyr232_1
            -75;    % 11-15: L4_LBC_cACint209_1
            -75;    % 16-20: L5_TTPC2_cADpyr232_1
            -75;    % 21-25: L4_PC_cADpyr230_1
            -75;    % 26-30: L1_NGC-DA_bNAC219_1
            -75;    % 31-35: L1_SLAC_cNAC187_1
            -75;    % 36-40: L6_TPC_L4_cADpyr231_1
            -70;    % 41-45: L5_STPC_cADpyr232_1
            -70;    % 46-50: L5_TTPC1_cADpyr232_1
            -70     % 51-55 L1_NGC-DA_cNAC187_1
            ], num_clones, 1);

if ~isscalar(cell_id) || any( ~isnumeric(cell_id) | (cell_id > length(default_v_inits) ) | (cell_id <= 0) | (round(cell_id)~= cell_id ))
    v_init = -75; 
    fprintf('\tInvalid cell id. Setting v_init to default value: %d mV.\n', v_init);
else
    v_init = default_v_inits(cell_id);
    fprintf('\tSetting specific v_init for cell id %d to %d mV.\n', cell_id, v_init);
end

end
