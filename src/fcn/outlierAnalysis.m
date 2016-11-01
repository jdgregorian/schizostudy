function outlierAnalysis(data, dim, varargin)
% outlierAnalysis(data, dim, settings) provides outlier analysis of 'data'
%
% Input:
%   data - data to finding outliers
%   dim  - dimensions of data to proceed (columns of data)
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'method'        - method to use for analysis
%                'showNOutliers' - number of outliers to mark | double
%                'title'         - plot title | string 
%
% See Also:
%   findOutliers

  if nargin < 2
    if nargin < 1
      help clusterAnalysis
      return
    end
    dim = 1:size(data, 2);
  end

  % parse function settings
  settings = settings2struct(varargin);
  method = defopts(settings, 'method', 'mahal');
  showNOut = defopts(settings, 'showNOutliers', 5);
  plotTitle = defopts(settings, 'title', [num2str(length(dim)), 'D']);

  % reduce dimension
  actualData = data(:, dim);

  % find outliers
  [~, mDist, sortId] = findOutliers(actualData, method);
  
  % plot distances
  switch method
    % mahalanobis distance
    case {'mahal', 'mahalanobis'}
      
      figure()
      hold on
      stem(mDist)
      scatter(sortId(1:showNOut), mDist(sortId(1:showNOut)), 'o', 'red', 'filled') 
      xlabel('Patient number')
      ylabel('Mahalanobis distance')
      title(plotTitle)
      hold off
      
    otherwise
      warning('Method %s is not implemented.', method)
      return
  end

  fprintf('%d most probable outlier ids in %dD:\n', showNOut, length(dim))
  fprintf('%s\n', num2str(sortId(1:showNOut)'))

end