function resultTable(avgPerformance, varargin)
% prints result table

  if nargin < 1
    help printResultTable
    return
  end
  
  [nSettings, nData] = size(avgPerformance);
  % parse settings
  settings = settings2struct(varargin);
  settings.FID = defopts(settings, 'FID', 1);
  def_methods = arrayfun(@(x) ['method_1', num2str(x)], 1:nSettings);
  settings.methods = defopts(settings, 'Method', def_methods);
  def_data = arrayfun(@(x) ['data_1', num2str(x)], 1:nData);
  settings.datanames = defopts(settings, 'Datanames', def_data);
  
  printTable(FID, avgPerformance, settings)
end

function printTable(FID, data, settings)
% prints text table to file FID

  % head row
  fprintf('\nMethod |');
  cellfun(@(x) fprintf(FID, ' %s', x), settings.data)
  fprintf('\n')
  
  % result rows
  for s = 1:size(data, 1)
    fprintf(FID, '%s | ', settings.methods{s});
    arrayfun(@(x) fprintf(FID, ' %f', x()), settings.data)
  end
end