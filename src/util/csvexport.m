function csvexport(data, matrix, filename)
% Exports matrix from MAT file 'data' to csv file in 'filename'
% Input:
%   data     - name of source file | string
%   matrix   - matrix (or its name) to export | double (string)
%   filename - name of output file | string
%
% Example:
% csvexport('data\data_FC_203subjects.mat','FC','data\schizo.csv')
%
% See Also:
% reduceData

if nargin == 2
  filename = [data(1:end-3),'csv'];
elseif ~strcmp(filename(end-3:end),'.csv')
  filename = [filename,'.csv'];
end

load(data)

if ischar(matrix)
  eval(['matrix = ',matrix,';'])
end

Nsubjects = size(matrix,1);
matDim = size(matrix,2);

% transform 3D connectivity matrix to matrix where each subject has its own row
% and each feature one column
connectVector = NaN(Nsubjects,matDim*(matDim-1)/2);
for i = 1:Nsubjects
    oneFC = shiftdim(matrix(i,:,:),1);
    connectVector(i,:) = transpose(nonzeros(triu(oneFC+5)-6*eye(matDim)))-5;
end

% write to csv file
dlmwrite(filename,connectVector,'precision', '%e')

end