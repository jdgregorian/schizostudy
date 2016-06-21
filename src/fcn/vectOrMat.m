function [vector, matrix, names] = vectOrMat(datafile)
% [vector, matrix, names] = vectOrMat(datafile) loads vector and matrix 
% from loaded datafile structure
%
% Input:
%    datafile - structure from loaded file (datafile = load(file))
%
% Output:
%    vector - vector from datafile
%    matrix - matrix from datafile
%    names  - structure containing names of vector and matrix fields in
%             datafile

  vector = [];
  matrix = [];
  names = [];
  
  if nargin == 0
    help vectOrMat
    return
  end

  datanames = fieldnames(datafile);
  value1 = getfield(datafile, datanames{1});
  value2 = getfield(datafile, datanames{2});
  
  % matrix and vector filter
  if ismatrix(value1) && isvector(value2)
    matrix = value1;
    vector = value2;
    names.matrix = datanames{1};
    names.vector = datanames{2};
  elseif ismatrix(value2) && isvector(value1)
    matrix = value2;
    vector = value1;
    names.matrix = datanames{2};
    names.vector = datanames{1};
  else
    return
  end
  
end