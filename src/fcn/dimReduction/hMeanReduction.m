function [reducedData, meanData] = hMeanReduction(data, nDim, minVal)
% reducedData = hMeanReduction(data, labels, nDim, minDif) provides 
% feature reduction of 'data' to 'nDim'-dimensional data (at maximum) by
% omitting features with low averages of values
%
% Input:
%   data   - N x M data matrix | double
%   nDim   - dimension of reduced data | integer
%   minVal - minimal feature value (default 0)| double
%
% Output:
%   reducedData - N x nDim data | double

  reducedData = [];
  if nargin == 0
    help hMeanReduction
    return
  end
  
  if nargin < 4
    % minimal value of average
    minVal = 0;
    if nargin < 3
      nDim = size(data, 2);
    end
  end

  meanData = mean(data, 1);
  reducedData = data(:, meanData >= minVal);
  redDim = size(reducedData, 2);

  % check if some data left
  if redDim == 0
    warning(['Too severe constraints! Preventing emptyness of reduced', ...
      'dataset by keeping one dimension with the highest average.'])
    [meanData, maxId] = max(meanData);
    reducedData = data(:, maxId(1));
  % reduction by dimensions with the highest averages
  elseif redDim > nDim
    meanData = meanData(meanData >= minVal);
    [~, meanId] = sort(meanData, 'descend');
    reducedData = reducedData(:, meanId(1:nDim));
    meanData = meanData(meanId(1:nDim));
  else
    meanData = meanData(meanData >= minVal);
  end
end