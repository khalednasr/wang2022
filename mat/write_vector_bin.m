% Input target directory, and column vectors
% writes vector to text file in binary format with name, varname.txt
function write_vector_bin(direc ,varargin)

file_ext = '.txt';
header(2) = 4; % for double format
    
for ii = 1:length(varargin)
    file_name = [direc, filesep, inputname(ii+1), file_ext];
    fid = fopen(file_name,'w');
    
    vector = varargin{ii};
    header(1) = length(vector);
    
    fwrite(fid, header, 'int32');
    fwrite(fid, vector, 'double');
    fclose(fid);
end
end
