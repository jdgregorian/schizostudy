function reducedData = medianReduction(data, labels, nDim, minDif)
% reducedData = medianReduction(data, labels, nDim, minDif) provides 
% feature reduction of 'data' to 'nDim'-dimensional data (at maximum) using 
% Honza Kalina's suggestion: 
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

  reducedData = [];
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

  medData = median(data, 1);
  greaterSub = data > repmat(medData, Nsubjects, 1);
  greaterOnes = sum(greaterSub & repmat(labels, 1, dim), 1);
  greaterZeros = sum(greaterSub & repmat(~labels, 1, dim), 1);
  % count median difference coefficient
  nDif = abs(greaterOnes - greaterZeros) + abs(nOnes - nZeros - greaterOnes + greaterZeros);

  reducedData = data(:, nDif >= minDif);
  redDim = size(reducedData, 2);

  % check if some data left
  if redDim == 0
    warning(['Too severe constraints! Preventing emptyness of reduced',...
      'dataset by keeping one dimension with the highest difference coefficient.'])
    [~, minId] = min(nDif);
    reducedData = data(:, minId(1));
  % reduction by dimensions with the highest difference coefficients
  elseif redDim > nDim
    [~, difId] = sort(nDif(nDif >= minDif), 'descend');
    reducedData = reducedData(:, difId(1:nDim));
  end
end