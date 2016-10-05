function [reducedData, idVector, meanData] = hMeanReduction(data, nDim, minVal)
% [reducedData, idVector, meanData] = 
%                              hMeanReduction(data, labels, nDim, minDif) 
% provides feature reduction of 'data' to 'nDim'-dimensional data 
% (at maximum) by omitting features with low averages of values.
%
% Input:
%   data   - N x M data matrix | double
%   nDim   - dimension of reduced data | integer
%   minVal - minimal feature value (default 0)| double
%
% Output:
%   reducedData - N x nDim data | double
%   idVector    - vector of dimensions to keep | logical
%   meanData    - nDim means of data | double vector
%
% See Also:
%   pcaReduction, ttestReduction, kendallReduction, classifier
  
  if nargout > 0
    reducedData = [];
    idVector = [];
    meanData = [];
  end
  if nargin == 0
    help hMeanReduction
    return
  end
  
  if nargin < 3
    % minimal value of average
    minVal = 0;
    if nargin < 2
      nDim = size(data, 2);
    end
  end

  meanData = mean(data, 1);
  % create vector of dimensions to keep
  idVector = meanData >= minVal;

  % check if some data left
  if sum(idVector) == 0
    warning(['Too severe constraints! Preventing emptyness of reduced', ...
      'dataset by keeping dimensions with the highest averages.'])
    [~, ~, I] = unique(meanData);
    maxId = I == max(I);
    idVector(maxId) = true;
  end
  
  % reduction by dimensions with the highest averages
  if sum(idVector) > nDim
    [~, meanId] = sort(meanData, 'descend');
    idVector(meanId(nDim + 1:end)) = false;
  end
  
  % return reduced data
  reducedData = data(:, idVector);
  meanData = meanData(idVector);
  
end