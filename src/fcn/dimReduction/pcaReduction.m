function [reducedData, transMatrix] = pcaReduction(data, nDim)
% [reducedData, transMatrix] = pcaReduction(data, nDim) provides principle 
% component analysis feature reduction of 'data' to 'nDim'-dimensional data
% (at maximum).
%
% Input:
%   data - N x M data matrix | double
%   nDim - dimension of reduced data | integer
%
% Output:
%   reducedData - N x nDim data | double
%   transMatrix - matrix of transformation data to new coordinate system |
%                 double
% See Also:
%   ttestReduction, kendallReduction, classifier

  if nargout > 0
    reducedData = [];
    transMatrix = [];
  end
  if nargin == 0
    help pcaReduction
    return
  end
  
  [Nsubjects, dim] = size(data);
  if nargin == 1
    nDim = dim;
  end
  if nDim > Nsubjects - 1
    nDim = Nsubjects - 1;
  end

  % pca
  [transMatrix, transData] = pca(data);
  nDim = min(size(transData, 2), nDim);
  reducedData = transData(:, 1:nDim);
end