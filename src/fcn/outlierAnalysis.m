function outlierAnalysis(data, dim, varargin)
% outlierAnalysis(data, dim, settings) provides outlier analysis of 'data'
%
% Input:
%   data     - data to finding outliers or cell-array of data
%   dim      - dimensions of data to proceed (columns of data)
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'dataNames'  - names of input data
%                'method'     - method to use for analysis
%                'showMaxOut' - maximal number of outliers to mark | double
%                'title'      - plot title | string 
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
  if ~iscell(data)
    data = {data};
  end
  % gain input settings
  nData = length(data);
  nPointData = cellfun(@(x) size(x, 1), data);
  pointDatId = [];
  for dat = 1:nData
    pointDatId = [pointDatId; dat*ones(nPointData(dat), 1)];
  end
  useDim = dim;
  dim = length(useDim);

  % parse function settings
  settings = settings2struct(varargin{:});
  defNames = arrayfun(@(x) ['data', num2str(x)], 1:nData, 'UniformOutput', false);
  datanames = defopts(settings, 'dataNames', defNames);
  method = defopts(settings, 'method', 'mahal');
  showMaxOut = defopts(settings, 'showMaxOut', floor(sum(nPointData)/5));
  plotTitle = defopts(settings, 'title', [num2str(dim), 'D']);

  % reduce dimension
  actualData = cell2mat(data');
  actualData = actualData(:, useDim);

  % remove settings for this function
  extraField = {'showMaxOut', 'title'};
  extraFieldID = isfield(settings, extraField);
  settings = rmfield(settings, extraField(extraFieldID));
  
  % find outliers
  [~, outValue, sortId] = findOutliers(actualData, method, settings);
  
  % plot distances
  switch method
    % mahalanobis distance
    case {'mahal', 'mahalanobis'}
      mDist = outValue;
      % find outliers in distance using Tukey's test
      [~, showOut] = findOutliers(mDist, 'tukey');
      showId = find(showOut);
      
      % create plot
      figure()
      hold on
      for dat = 1:nData
        stem(find((pointDatId == dat)), mDist(pointDatId == dat))
      end
      scatter(showId, mDist(showId), 'o', 'red', 'filled') 
      xlabel('Point number')
      ylabel('Mahalanobis distance')
      title(plotTitle)
      legend([datanames, 'possible outlier'])
      hold off
      
      % print most probable outliers
      fprintf('%d most probable outlier ids according to Tukey''s test in %dD:\n', sum(showOut), dim)
      fprintf('%s\n', num2str(sortId(1: sum(showOut))'))
      
    % Tukey's test
    case 'tukey'
      % numbers of outlier dimensions
      outDim = sum(outValue, 2);
      trueOutDim = outDim > 0;
      % IDs of outliers
      tOutId = find(trueOutDim);
      % values of outliers
      tOutVal = outDim(trueOutDim);
      % outliers to mark in graph
%       tOutShow = tOutVal >= median(tOutVal);
      tOutShow = tOutVal >= (max(tOutVal) + 1)/2;
      % confront with maximal number to show settings
      if sum(tOutShow) > showMaxOut
        tOutShow = tOutVal > median(tOutVal);
      end
      
      % create plot
      figure()
      hold on
      for dat = 1:nData
        stem(find((pointDatId == dat)), outDim(pointDatId == dat))
      end
      scatter(tOutId(tOutShow), tOutVal(tOutShow), 'o', 'red', 'filled') 
      xlabel('Point number')
      ylabel('Number of outlier dimensions')
      title(plotTitle)
      legend([datanames, 'possible outlier'])
      hold off
      
      % print most probable outliers (number of outlier dimensions greater
      % or equal to median)
      [~, outId] = sort(tOutVal(tOutShow), 'descend');
      fprintf('%d most probable outlier ids in %dD:\n', length(outId), dim)
      tOutId = tOutId(tOutShow);
      fprintf('%s\n', num2str(tOutId(outId)'))
      
    otherwise
      warning('Method %s is not implemented.', method)
      return
  end



end