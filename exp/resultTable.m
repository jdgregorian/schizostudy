function resultTable(avgPerformance, varargin)
% resultTable(avgPerformance, settings) prints result table
%
% Input:
%   avgPerformance - array of average performances to print (of size NxM, 
%                    where N is the number of settings and M is the number 
%                    of different datasets) | double
%   settings       - name-value pairs (or structure with fields) of table 
%                    settings:
%     FID       - identifier of file to print in | double
%     Method    - names of methods in table (rows) | cell-array of strings
%     Datanames - names of data in table (columns) | cell-array of strings
%
% See Also:
%   listSettingsResults

  if nargin < 1
    help resultTable
    return
  end
  
  [nSettings, nData] = size(avgPerformance);
  % parse settings
  settings = settings2struct(varargin);
  FID = defopts(settings, 'FID', 1);
  def_methods = arrayfun(@(x) ['method_', num2str(x)], 1:nSettings, 'UniformOutput', false);
  settings.methods = defopts(settings, 'Method', def_methods);
  def_data = arrayfun(@(x) ['data_1', num2str(x)], 1:nData, 'UniformOutput', false);
  settings.datanames = defopts(settings, 'Datanames', def_data);
  tableFormat = defopts(settings, 'Format', 'txt');
  
  switch tableFormat
    case 'txt'
      printTable(FID, avgPerformance, settings)
    otherwise
      error('Format %s is not implemented.', tableFormat)
  end
end

function printTable(FID, data, settings)
% prints text table to file FID

  maxLengthMethod = max(max(cellfun(@length, settings.methods)), length('Method'));
  methodSize = maxLengthMethod + 1;
  perfSize = max(max(cellfun(@length, settings.datanames)) + 1, 8);

  % head row
  fprintf(FID, '  Method%s', gap(methodSize, 'Method'));
  cellfun(@(x) fprintf(FID, '%s%s', gap(perfSize, x), x), settings.datanames);
  fprintf(FID, '\n');
  
  % result rows
  for s = 1:size(data, 1)
    fprintf(FID, '  %s%s', settings.methods{s}, gap(methodSize, settings.methods{s}));
    arrayfun(@(x) printPerf(FID, perfSize, data(s, x)), 1:size(data, 2))
    fprintf(FID, '\n');
  end
end

function printTexTable(FID, data, settings)
% prints tex table to file FID
  
end

function printPerf(FID, maxLength, perf)
% prints performance perf to FID with appropriate length
  if isnan(perf)
    fprintf(FID, '%s---  ', gap(maxLength, 5));
  else
    if perf < 1
      n = 2;
      if perf < 0.1
        n = 1;
      end
    else
      n = 3;
    end
    fprintf(FID, '%s%0.2f%%', gap(maxLength, n + 4), perf*100);
  end
end

function g = gap(maxLength, n)
% generates spaces of length maxLength - n
  if ischar(n)
    n = length(n);
  end
  g = ' '*ones(1, maxLength - n);
end