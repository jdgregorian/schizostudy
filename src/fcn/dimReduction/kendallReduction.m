function reducedData = kendallReduction(data, labels, nDim, treshold)
% reducedData = kendallReduction(data, labels, nDim) provides feature 
% reduction of 'data' to 'nDim'-dimensional data (at maximum) using Kendall
% tau rank coefficient (according to Hui 2009).
%
% Input:
%   data     - N x M data matrix | double
%   labels   - N x 1 label vector | double
%   nDim     - dimension of reduced data | integer
%   treshold - maximal kendall tau rank value | double
%
% Output:
%   reducedData - N x nDim data | double


  reducedData = [];
  [Nsubjects, dim] = size(data);
  
  if nargin < 4
    % minimal Kendall tau rank value
    treshold = -1;
    if nargin < 3
      nDim = dim;
      if nargin < 1
        help kendallReduction
        return
      end
    end
  end

  % kendall
  nOne = sum(labels);
  nZero = Nsubjects - nOne;
  nc = zeros(1, dim);
  % for each value from one group count equalities for each value from the
  % other
  for ind = 1:nZero
    for counterInd = nZero + 1:Nsubjects
      nc = nc + (sign(data(ind, :)-data(counterInd, :)) == true(1, dim)*sign(labels(ind)-labels(counterInd)));
    end
  end
  nd = ones(1, dim) * nOne * nZero - nc;
  tau = (nc - nd)/(nZero*nOne); % count Kendall tau ranks

  [sortedTau, tauId] = sort(abs(tau), 'descend');
  reducedData = data(:, tauId(1:nDim)); % reduction by dimension setting
  reducedData = reducedData(:, sortedTau(1:nDim) > treshold); % reduction by treshold

  if isempty(reducedData) % check if some data left
    warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
    reducedData = data(:, tauId(1));
  end
end