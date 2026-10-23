% input nrn_model_ver and current params_struct m, or no params struct
function m_out = output_morph_params(nrn_model_ver, m_in)
if nargin < 2
   m_in = struct;
end

if strcmp(nrn_model_ver,'R_J_Un')            % Rat Juvenile (P14), Unmyelinated axon, no scaling
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 0;
    scale_axon_diam = 1;
    scale_apic_diam = 1;
    scale_basal_diam = 1;
    scale_soma_area = 1;
    scale_basal_L = 1;
    min_myelin_diam = 0.2;                	% um - matches paper
    max_myelin_order = 0;    
elseif strcmp(nrn_model_ver,'R_A_My')       % Rat Adult (P60), with myelinated axon, using Zhu 2000 scaling
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 1;
    scale_axon_diam = 1.322;                % using Zhu 2000 L5 pc soma scaling
    scale_apic_diam = 1.248;                % using Romand 2011 L5 PC growth
    scale_basal_diam = 1.133;               % using Romand 2011 L5 PC growth
    scale_soma_area = 1.322;                % using Zhu 2000 L5 pc soma scaling
    scale_basal_L = 1.17;                   % using Romand 2011 L5 PC growth
    min_myelin_diam = 0.2;                  % um - matches paper
    max_myelin_order = 0;
elseif strcmp(nrn_model_ver,'H_A_My_v1')	% Human Adult, Myelinated axon v1 (used in original 2017 paper figures)
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 1;
    scale_axon_diam = 2.41;
    scale_apic_diam = 1.8;
    scale_basal_diam = 1.8;
    scale_soma_area = 2.41;
    scale_basal_L = 1.17;
    min_myelin_diam = 0.05;               	% um - used for original figures
    max_myelin_order = 0;
elseif strcmp(nrn_model_ver,'H_A_My_v2')  	% Human Adult, Myelinated axon v1 (same as 2017 paper, but uses correct min_myelinD)
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 1;
    scale_axon_diam = 2.41;
    scale_apic_diam = 1.8;
    scale_basal_diam = 1.8;
    scale_soma_area = 2.41;
    scale_basal_L = 1.17;
    min_myelin_diam = 0.2;               	% um - matches text of paper
    max_myelin_order = 0;
elseif strcmp(nrn_model_ver,'H_A_My_v3')	% Human Adult, Myelinated axon v3, using L2/3 PC rat BB: human Eyal 2018
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 1;
    scale_axon_diam = 2.453;                % use soma scaling
    scale_apic_diam = 1.876;
    scale_basal_diam = 1.946;
    scale_soma_area = 2.453;
    scale_basal_L = 1.17;                   % using Romand 2011 L5 PC growth
    min_myelin_diam = 0.2;                  % um - matches paper
    max_myelin_order = 0;
elseif strcmp(nrn_model_ver,'H_A_Un')       % Human Adult, Unmyelinated axon, using L2/3 PC rat BB: human Eyal 2018
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 0;
    scale_axon_diam = 2.453;                % use soma scaling
    scale_apic_diam = 1.876;
    scale_basal_diam = 1.946;
    scale_soma_area = 2.453;
    scale_basal_L = 1.17;                   % using Romand 2011 L5 PC growth
    min_myelin_diam = 0.2;                  % um - matches paper
    max_myelin_order = 0;
elseif strcmp(nrn_model_ver,'M_A_my')       % Mouse Adult, (>3 months), Myelinated axon, no scaling compared to rats
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 1;
    scale_axon_diam = 1;
    scale_apic_diam = 1;
    scale_basal_diam = 1;
    scale_soma_area = 1;
    scale_basal_L = 1;                      % 
    min_myelin_diam = 0.2;                  % um - matches paper
    max_myelin_order = 0;
else                                        % Default parameters, no replacement, no pruning, no myelination and no scaling
    replace_axon = 0;
    prune_axon = 0;
    myelinate_axon = 0;
    scale_axon_diam = 1;
    scale_apic_diam = 1;
    scale_basal_diam = 1;
    scale_soma_area = 1;
    scale_basal_L = 1;
    min_myelin_diam = 0;
    max_myelin_order = 0;
    nrn_model_ver = 'Default';
end

fprintf('\tUsing neuron model parameters for version: %s.\n', nrn_model_ver)

m_out = m_in; 
m_out.myelinate_axon = myelinate_axon;
m_out.prune_axon = prune_axon;
m_out.replace_axon = replace_axon;
m_out.scale_axon_diam = scale_axon_diam;
m_out.scale_apic_diam = scale_apic_diam;
m_out.scale_basal_diam = scale_basal_diam;
m_out.scale_soma_area = scale_soma_area;
m_out.scale_basal_L = scale_basal_L;
m_out.min_myelin_diam = min_myelin_diam;
m_out.max_myelin_order = max_myelin_order;

end
    
