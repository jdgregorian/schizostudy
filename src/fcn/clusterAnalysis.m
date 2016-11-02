function clusterAnalysis(data, dim, varargin)
% clusterAnalysis(data, dim, settings) provides cluster analysis of 'data'
%
% Input:
%   data - data to cluster
%   dim  - dimensions of data to proceed (columns of data)
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'maxGroups' - maximal number of groups in denderogram
%                'title'     - dendrogram title | string 
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
  settings = settings2struct(varargin{:});
  maxGroups = defopts(settings, 'maxGroups', 20);
  dendrTitle = defopts(settings, 'title', [num2str(length(dim)), 'D']);

  % reduce dimension
  actualData = data(:, dim);

  % count distances
  dataDist = pdist(actualData);
  % create agglomerative hierarchical cluster tree
  clustData = linkage(dataDist);
  % display dendrogram
  [~, dendrID] = dendrogram(clustData, maxGroups);
  hold on
  xlabel('Point group')
  ylabel('Distance')
  title(dendrTitle)
  hold off

  % print properties of data
  fprintf('Numbers of points in groups:\n\n')
  fprintf('Group:   %s\n', num2str(1:maxGroups))
  fprintf('Number:')
  for i = 1:maxGroups
    fprintf(' %2.0f ', sum(dendrID == i))
  end
  fprintf('\n')

end