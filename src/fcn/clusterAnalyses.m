function clusterAnalyses(data, dim, varargin)
% clusterAnalyses(data, dim, settings) provides cluster analyses of 'data'
%
% Input:
%   data - data to cluster
%   dim  - dimensions of data to proceed (columns of data)
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'maxGroups' - maximal number of groups in denderogram
%

  if nargin < 2
    if nargin < 1
      help clusterAnalyses
      return
    end
    dim = 1:size(data, 2);
  end

  % parse function settings
  settings = settings2struct(varargin);
  maxGroups = defopts(settings, 'maxGroups', 20);

  % reduce dimension
  actualData = data(:, dim);

  % count distances
  dataDist = pdist(actualData);
  % create agglomerative hierarchical cluster tree
  clustData = linkage(dataDist);
  % display dendrogram
  [~, dendrID] = dendrogram(clustData, maxGroups);
  hold on
  xlabel('Patient group')
  ylabel('Distance')
  hold off

  % print properties of data
  fprintf('Numbers of patients in groups:\n\n')
  fprintf('Group: ')
  for i = 1:maxGroups
    fprintf(' %2.0f ', i)
  end
  fprintf('\n')
  fprintf('Number:')
  for i = 1:maxGroups
    fprintf(' %2.0f ', sum(dendrID == i))
  end
  fprintf('\n')

end