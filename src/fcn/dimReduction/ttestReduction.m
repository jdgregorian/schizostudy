function reducedData = ttestReduction(data, labels, nDim, alpha)
% reducedData = ttestReduction(data, labels, nDim) provides feature 
% reduction of 'data' to 'nDim'-dimensional data (at maximum) using t-test.
%
% Input:
%   data - N x M data matrix | double
%   labels - N x 1 label vector | double
%   nDim - dimension of reduced data | integer
%   alpha - feature significance level | double
%
% Output:
%   reducedData - N x nDim data | double


  reducedData = [];
  dim = size(data, 2);
  
  if nargin < 4
    % significance level
    alpha = 0.05;
    if nargin < 3
      nDim = dim;
      if nargin < 1
        help ttestReduction
        return
      end
    end
  end

  % t-test
  [t2, p] = ttest2(data(logical(labels), :), data(~logical(labels), :), ...
                   'Alpha', alpha, 'Vartype', 'unequal');
  % reduction by t-test
  reducedData = data(:, logical(t2));
  % check if some data left
  if isempty(reducedData) 
    warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
    [~, pMinId] = min(p);
    reducedData = data(:, pMinId(1));
  % reduction by dimensions with the lowest p-values 
  elseif sum(t2) > nDim   
    [~, pId] = sort(p(logical(t2)));
    reducedData = reducedData(:, pId(1:nDim));
  end
end