% CELL_MODEL_NAME = cellmodelnames(CELL_MODEL_ID) outputs the cell model
% names corresponding to CELL_MODEL_ID. CELL_MODEL_ID must be an integer or
% integer array with elements within the range between 1 to 55. For scalar
% input, the output CELL_MODEL_NAME is a string. For array input, the
% output is a cell array containing of strings.
% cellmodelnames(CELL_MODEL_ID, TYPE) outputs the cell types of model
% corresponding to CELL_MODEL_ID. TYPE must be an integer in the range
% between 0 to 3. cellmodelnames(CELL_MODEL_ID, 0) is equivelent to 
% cellmodelnames(CELL_MODEL_ID). TYPE=1 outputs the full name of the cell 
% type; TYPE=2 outputs the descriptive categories; TYPE=3 outputs the 
% abbreviated nameof the cell type.
%
% CELL_MODEL_ID
% 01-05: L2/3 continuous adapting pyramidal cell
% 06-10: L5 untufted continuous adapting pyramidal cell 
% 11-15: L4 continuous accomodating Large Basket Cell
% 16-20: L5 continuous adapting thick tufted pyramidal cell, early bifurcating apical tuft
% 21-25: L4 continuous adapting pyramidal cell
% 26-30: L1 burst-non accomodating Neurogliaform cell w/ dense axonal arbor
% 31-35: L1 continuous non-accomodating Large Axon Cell
% 36-40: L6 Tufted Pyramidal Cell with dendritic tuft in layer 4
% 41-45: L5 Slender-tufted pyramidal cell
% 46-50: L5 Thick Tufted Pyramidal cell, late bifurcating tuft
% 51-55: L1 continuous non-accomodating NGC w/ dense axon

function cell_model_name = cellmodelnames(cell_model_id, type)

switch nargin
    case 1
        type = 0;
    case 2
        if ~isscalar(type) || any( ~isnumeric(type) | (type > 3 ) | (type < 0) | (round(type)~= type ))
            error('The input TYPE is invalid.')
        end
    otherwise
        error('Incorrect number of inputs.');
end

% Blue Brain cells
num_cell_types = 11;
num_clones = 5;

if ~isvector(cell_model_id) || any( ~isnumeric(cell_model_id) | (cell_model_id > num_cell_types * num_clones ) | (cell_model_id <= 0) | (round(cell_model_id)~= cell_model_id ))
    error('The input CELL_MODEL_ID is invalid.')
end

cell_model_types_full = repelem({
    'L23_PC_cADpyr229';         % 01-05: L2/3 continuous adapting pyramidal cell
    'L5_UTPC_cADpyr232';        % 06-10: L5 untufted continuous adapting pyramidal cell 
    'L4_LBC_cACint209';         % 11-15: L4 continuous accomodating large basket cell
    'L5_TTPC2_cADpyr232';       % 16-20: L5 continuous adapting thick tufted pyramidal cell, early bifurcating apical tuft
    'L4_PC_cADpyr230';          % 21-25: L4 continuous adapting pyramidal cell
    'L1_NGC-DA_bNAC219';        % 26-30: L1 burst-non accomodating neurogliaform cell with dense axonal arbor
    'L1_SLAC_cNAC187';          % 31-35: L1 continuous non-accomodating large axon cell
    'L6_TPC_L4_cADpyr231';      % 36-40: L6 tufted pyramidal cell with dendritic tuft in layer 4
    'L5_STPC_cADpyr232';        % 41-45: L5 slender-tufted pyramidal cell
    'L5_TTPC1_cADpyr232';       % 46-50: L5 thick tufted pyramidal cell, late bifurcating tuft
    'L1_NGC-DA_cNAC187'         % 51-55: L1 continuous non-accomodating neurogliaform cell with dense axon
    }, num_clones, 1);
cell_model_types_short = repelem({
    'L23_PC';
    'L5_UTPC';
    'L4_LBC';
    'L5_TTPC2';
    'L4_PC';
    'L1_NGC-DA';
    'L1_SLAC';
    'L6_TPC';
    'L5_STPC';
    'L5_TTPC1';
    'L1_NGC-DA2';
    }, num_clones, 1);
cell_type_categories = repelem({ % Categories corresponding to cell types above
    'L2/3 Pyramidal Cells';
    'L5/6 Pyramidal Cells';
    'Interneurons';
    'L5/6 Pyramidal Cells';
    'L4 Pyramidal Cells';
    'Interneurons';
    'Interneurons';
    'L5/6 Pyramidal Cells';
    'L5/6 Pyramidal Cells';
    'L5/6 Pyramidal Cells';
    'Interneurons'
    }, num_clones, 1);

cell_models = cell(size(cell_model_types_full));
for ii = 1:num_cell_types
    for jj = 1:num_clones
        ind = (ii-1)*num_clones+jj;
        cell_models{ind} = sprintf('%s_%d',cell_model_types_full{ind},jj);        
    end
end

switch type
    case 0
        output = cell_models;
    case 1
        output = cell_model_types_full;
    case 2
        output = cell_type_categories;
    case 3
        output = cell_model_types_short;
end

if isscalar(cell_model_id)
    cell_model_name = output{cell_model_id};
else
    cell_model_name = output(cell_model_id);
end

end
