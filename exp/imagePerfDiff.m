function imagePerfDiff(exp1, exp2, varargin)
% imagePerfDiff(exp1, exp2, settings) images performance differences 
% between experiments exp1 and exp2. The difference is calculated as 
% perf(exp1) - perf(exp2).
%
% Input:
%   exp1     - folder containing files of the first experiment
%   exp2     - folder containing files of the second experiment
%   settings - pairs of property (string) and value, or struct with 
%              properties as fields:
%                'DataLabels' - names of experimental data | cell-array of
%                               string
%                'MaxPerf'    - maximal value of performance to show | 
%                               [-1;1]
%                'MinPerf'    - minimal value of performance to show | 
%                               [-1;1]
%                'Title'      - title of resulting image | string

  if nargin < 2
    help imagePerfDiff
    return
  end

  % parse function settings
  if ~isdir(exp1)
    warning('Folder %s does not exist! Results cannot be displayed!', exp1)
    return
  end
  if ~isdir(exp2)
    warning('Folder %s does not exist! Results cannot be displayed!', exp2)
    return
  end
  settings = settings2struct(varargin);
  diff_lb = defoptsi(settings, 'MinPerf', -1);
  diff_ub = defoptsi(settings, 'MaxPerf',  1);
  image_title = defoptsi(settings, 'title', 'Perfomance difference');

  % load results
  [avgPerformance1, ~, method, data1] = returnResults(exp1);
  avgPerformance2 = returnResults(exp2);
  assert(all(size(avgPerformance1) == size(avgPerformance2)), ... 
         'Number of methods or the number of data does not correspond to each other.')
       
  % data labels
  nData = length(data1);
  defDataLabels = cellfun(@num2str, num2cell(1:nData), 'UniformOutput', false);
  dataLabels = defoptsi(settings, 'datalabels', defDataLabels);
  if length(dataLabels) < nData
    warning('Number of data labels is lower than the number of data (%d).', nData)
    dataLabels(end+1 : nData) = defDataLabels(length(dataLabels)+1 : nData);
  end

  % compute difference
  perf_diff = avgPerformance1 - avgPerformance2;
  % bound correction
  perf_diff(perf_diff > diff_ub) = diff_ub;
  perf_diff(perf_diff < diff_lb) = diff_lb;

  % display image
  image(perf_diff, 'CDataMapping','scaled')
  colorbar
  xlabel('Data')
  ax = gca;
  ax.XTick = 1:nData;
  ax.XTickLabel = dataLabels;
  ylabel('Methods')
  ax.YTick = 1:length(method);
  ax.YTickLabel = method;
  title(image_title)
  
  % print data description
  fprintf('Experiment data:\n')
  for d = 1:nData
    fprintf('  %s: %s\n', dataLabels{d}, data1{d});
  end

end