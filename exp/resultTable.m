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
%     Settings  - settings of methods in table | cell-array of struct
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
  settings.dataSettings = defopts(settings, 'Settings', cell(1, nSettings));
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

  methodStrings = cellfun(@(x, y) methodString(x, y), settings.methods, settings.dataSettings, 'UniformOutput', false);
  maxLengthMethod = max(max(cellfun(@length, methodStrings)), length('Method'));
  methodSize = maxLengthMethod + 1;
  perfSize = max(max(cellfun(@length, settings.datanames)) + 1, 8);

  % head row
  fprintf(FID, '  Method%s', gap(methodSize, 'Method'));
  cellfun(@(x) fprintf(FID, '%s%s', gap(perfSize, x), x), settings.datanames);
  fprintf(FID, '\n');
  
  % result rows
  for s = 1:size(data, 1)
    fprintf(FID, '  %s%s', methodStrings{s}, gap(methodSize, methodStrings{s}));
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

function ms = methodString(method, settings)
% generates string in accordance with method and its settings
  if isempty(settings)
    ms = method;
    return
  end
  
  addms = {};
  switch method
    % support vector machine
    case 'svm'
      if isfield(settings, 'svm')
        % kernel
        ker = defopts(settings.svm, 'kernel_function', []);
        if ~isempty(ker)
          addms{end+1} = ker(1:3);
        end
        % autoscaling
        auto = defopts(settings.svm, 'autoscale', []);
        if ~isempty(auto) && auto
          addms{end+1} = 'on';
        elseif ~isempty(auto) && ~auto
          addms{end+1} = 'off';
        end
      end
    % decision tree
    case 'tree'
      if isfield(settings, 'tree')
        if isfield(settings.tree, 'type')
          addms{end+1} = settings.tree.type(1:3);
        end
        if isfield(settings.tree, 'crit')
          addms{end+1} = settings.tree.crit(1:3);
        end
        if isnan(defopts(settings.tree, 'prune', []))
          addms{end+1} = 'opt';
        end
      end
    % random forest
    case 'rf'
      if isfield(settings, 'rf')
        if isfield(settings.rf, 'type') && strcmp(settings.rf.type, 'matlab')
          addms{end+1} = 'mtl';
        end
        if isfield(settings.rf, 'TreeType')
          addms{end+1} = settings.rf.TreeType(1:3);
        end
        if isfield(settings.rf, 'learning')
          addms{end+1} = settings.rf.learning(1:3);
        end
      end
    % k-nearest neighbours
    case 'knn'
      if isfield(settings, 'knn') && isfield(settings.knn, 'k')
        method = [num2str(settings.knn.k), '-nn'];
      else
        method = 'k-nn';
      end
    % discriminant analyses
    case {'lda', 'qda'}
      if isfield(settings, 'implementation') && strcmp(settings.implementation, 'matlab')
        addms{end+1} = 'mtl';
      elseif isfield(settings, 'implementation') && strcmp(settings.implementation, 'prtools')
        addms{end+1} = 'prt';
      end
  end
  
  % gridsearch
  if isfield(settings, 'gridsearch')
    addms{end+1} = 'grid';
  end
  
  % add extension to method name
  if ~isempty(addms) > 0
    add = [' - ', addms{1}];
    if length(addms) > 1
      for i = 2:length(addms)
        add = [add, ', ', addms{i}];
      end
    end
  else
    add = [];
  end
  ms = [method, add];
end