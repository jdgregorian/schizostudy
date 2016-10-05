function [reducedData, idVector] = medianReduction(data, labels, nDim, minDif)
% [reducedData, idVector] = medianReduction(data, labels, nDim, minDif) 
% provides feature reduction of 'data' to 'nDim'-dimensional data 
% (at maximum) using Honza Kalina's suggestion: 
%   Choose median value in each dimension, count how many individuals has 
%   greater or lower value.
%
% Input:
%   data   - N x M data matrix | double
%   labels - N x 1 label vector | double
%   nDim   - dimension of reduced data | integer
%   minDif - minimal number of differences | integer
%
% Output:
%   reducedData - N x nDim data | double
%   idVector    - vector of dimensions to keep | logical
%
% See Also:
%   pcaReduction, ttestReduction, kendallReduction, classifier

  if nargout > 0
    reducedData = [];
    idVector = [];
  end
  if nargin == 0
    help medianReduction
    return
  end
  
  [Nsubjects, dim] = size(data);
  nOnes = sum(labels);
  nZeros = Nsubjects - nOnes;
  
  if nargin < 4
    % minimal number of differences
    minDif = 2*abs(nOnes-nZeros);
    if nargin < 3
      nDim = dim;
    end
  end

  % calculate group medians
  medData = median(data, 1);
  greaterSub = data > repmat(medData, Nsubjects, 1);
  greaterOnes = sum(greaterSub & repmat(labels, 1, dim), 1);
  greaterZeros = sum(greaterSub & repmat(~labels, 1, dim), 1);
  % count median difference coefficient
  nDif = abs(greaterOnes - greaterZeros) + abs(nOnes - nZeros - greaterOnes + greaterZeros);

  % create vector of dimensions to keep
  idVector = nDif >= minDif;

  % check if some data left
  if sum(idVector) == 0
    warning(['Too severe constraints! Preventing emptyness of reduced',...
      'dataset by keeping dimensions with the highest difference coefficients.'])
    [~, ~, minId] = unique(nDif);
    idVector(minId == 1) = true;
  end
  % reduction by dimensions with the highest difference coefficients
  if sum(idVector) > nDim
    [~, difId] = sort(nDif(idVector), 'descend');
    idVector(difId(nDim + 1:end)) = false;
  end
  % return reduced data
  reducedData = data(:, idVector);
  
end