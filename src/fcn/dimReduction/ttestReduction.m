function [reducedData, idVector] = ttestReduction(data, labels, nDim, alpha)
% [reducedData, idVector] = ttestReduction(data, labels, nDim) provides 
% feature reduction of 'data' to 'nDim'-dimensional data (at maximum) 
% using t-test.
%
% Input:
%   data   - N x M data matrix | double
%   labels - N x 1 label vector | double
%   nDim   - dimension of reduced data | integer
%   alpha  - feature significance level | double
%
% Output:
%   reducedData - N x nDim data | double
%   idVector    - vector of dimensions to keep | logical
%
% See Also:
%   pcaReduction, kendallReduction, classifier

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
  % vector of significant dimensions
  idVector = logical(t2);

  % check if some data left
  if sum(idVector) == 0
    warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
    [~, pMinId] = min(p);
    idVector(pMinId(1)) = true;
  % reduction by dimensions with the lowest p-values 
  elseif sum(idVector) > nDim   
    [~, pId] = sort(p);
    idVector(pId(nDim + 1:end)) = false;
  end
  % reduction by t-test
  reducedData = data(:, idVector);
end