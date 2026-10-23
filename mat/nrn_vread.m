% For reading vector vwrite data from NEURON
function [data] = nrn_vread(simulation, file_name)

    data= [];
    fid = fopen(file_name,'r');
    if fid == -1
        fprintf(simulation.fid,'File %s unable to be opened.\n', file_name);
        return;
    else
    [data, count] = fread(fid, 'double');
    if length(data)>= 2
        fprintf(simulation.fid,'Successfully read %d samples from %s.\n',count-1, file_name);
        data = data(2:end); % remove extraneous number at beginning
    else
        fprintf(simulation.fid,'Empty vector in %s.\n',file_name);
    end
    
    fclose(fid);
    end
end
