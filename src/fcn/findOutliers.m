function [outProb, measureValue, sortId] = findOutliers(data, method, varargin)
% findOutliers(data, method) finds outliers among data using
% 'method'
%
% Input:
%   data   - NxM data matrix, where N is number of points and M is data
%            dimension
%   method - method used for finding outliers
%              'mahal' - computes mahalanobis distance between each point 
%                        and the rest of points
%
% Output:
%   outProb      - vector of probalities that point is an outlier | double
%   measureValue - values used to compute outProb
%                - differs according to the method
%   sortId       - points id sorted according to outProb | integer
%
% See Also:
%   clusterAnalyses

  if nargout > 0
    outProb = [];
    measureValue = [];
    sortId = [];
  end
  if nargin < 2
    if nargin < 1
      help findOutliers
      return
    end
    method = 'mahal';
  end
  % parse settings
  settings = settings2struct(varargin);
  
  nData = size(data, 1);
  switch method
    % mahalanobis distance
    case {'mahal', 'mahalanobis'}
      
      mDist = zeros(nData, 1);
      % compute mahalanobis distance between each point and the rest of
      % points
      for p = 1:nData
        useId = [1:p-1, p+1:nData];
        mDist(p) = mahal(data(p, :), data(useId, :));
      end
      outProb = mDist/sum(mDist);
      measureValue = mDist;
      
    otherwise
      warning('Method %s is not implemented.', method)
      return
  end
  
  % sort point identifiers according to the outlier probability
  [~, sortId] = sort(outProb, 'descend');

end 