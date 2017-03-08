function resultTable(avgPerformance, varargin)
% resultTable(avgPerformance, settings) prints result table
%
% Input:
%   avgPerformance - array of average performances to print (of size NxM, 
%                    where N is the number of settings and M is the number 
%                    of different datasets) | double
%   settings       - name-value pairs (or structure with fields) of table 
%                    settings:
%     ActualPerf - array of actual performances of classifier (same size as
%                  avgPerformance) | double
%     Datanames  - names of data in table (columns) | cell-array of strings
%     Format     - format of resulting table | {'txt', 'xls'}
%     FID        - identifier (or name) of file to print in | double or
%                  string (only string for 'xls' format)
%     Method     - names of methods in table (rows) | cell-array of strings
%     Settings   - settings of methods in table | cell-array of struct
%
% See Also:
%   listSettingsResults, returnResults

  if nargin < 1
    help resultTable
    return
  end
  
  [nSettings, nData] = size(avgPerformance);
  % parse settings
  settings = settings2struct(varargin);
  tableFormat = defopts(settings, 'Format', 'txt');
  if strcmp(tableFormat, 'xls')
    defFile = 'data.xls';
    FID = defopts(settings, 'FID', defFile);
    % xls printing needs string name as FID
    if isnumeric(FID)
      warning('FID for xls format has to be string. Changing output to %s.', defFile)
      FID = defFile;
    end
  else
    FID = defopts(settings, 'FID', 1);
  end
  def_methods = arrayfun(@(x) ['method_', num2str(x)], 1:nSettings, 'UniformOutput', false);
  settings.Method = defopts(settings, 'Method', def_methods);
  def_data = arrayfun(@(x) ['data_1', num2str(x)], 1:nData, 'UniformOutput', false);
  settings.Datanames = defopts(settings, 'Datanames', def_data);
  settings.Settings = defopts(settings, 'Settings', cell(1, nSettings));
  settings.methodStrings = cellfun(@(x, y) methodString(x, tableFormat, y), ...
                           settings.Method, settings.Settings, 'UniformOutput', false);
  settings.actualPerf = defopts(settings, 'ActualPerf', avgPerformance);
  
  % print table according to its format
  switch tableFormat
    
    case 'txt'
      if ~isnumeric(FID)
        fname = FID;
        FID = fopen(fname, 'w');
        assert(FID ~= -1, 'Cannot open %s !', fname)
        printTable(FID, avgPerformance, settings)
        fclose(FID);
      else
        printTable(FID, avgPerformance, settings)
      end
      
    case 'xls'
      printXlsTable(FID, avgPerformance, settings)
      
    otherwise
      error('Format %s is not implemented.', tableFormat)
  end
end

function printTable(FID, data, settings)
% prints text table to file FID

  methodStrings = settings.methodStrings;
  maxLengthMethod = max(max(cellfun(@length, methodStrings)), length('Method'));
  methodSize = maxLengthMethod + 1;
  perfSize = max(max(cellfun(@length, settings.Datanames)) + 1, 8);

  % head row
  fprintf(FID, '  Method%s', gap(methodSize, 'Method'));
  cellfun(@(x) fprintf(FID, '%s%s', gap(perfSize, x), x), settings.Datanames);
  fprintf(FID, '\n');
  
  % result rows
  for s = 1:size(data, 1)
    fprintf(FID, '  %s%s', methodStrings{s}, gap(methodSize, methodStrings{s}));
    arrayfun(@(x) printPerf(FID, perfSize, data(s, x)), 1:size(data, 2))
    fprintf(FID, '\n');
  end
end

function printXlsTable(fname, data, settings)
% prints table to xls file FID

% TODO:
%   - conditional format ??? is it possible?
%       - if not -> marking by extra symbol (to easily find out
%       differences)

  % datanames cannot contain some characters
  datanames = regexprep(settings.Datanames, '[\.\\\/]', '_'); % . \ /
  % compute averages and add them as the last row
  data(end+1, :) = nanmean(data);
  
  % prepare strings of data
  dataString = arrayfun(@(x) sprintf('%0.2f%%', 100*x), data, 'UniformOutput', false);
  % find differences between avgPerformance and actualPerformace
  diffPerf = data(1:end-1, :) ~= settings.actualPerf;
  diffPerfS = [diffPerf; false(1, size(data, 2))];
  % add actual performances
  dataString(diffPerfS) = arrayfun(@(x, y) sprintf('%0.2f%% (%0.2f%%)', 100*x, 100*y), ...
                           data(diffPerfS), settings.actualPerf(diffPerf), 'UniformOutput', false);
  % replace NaN's
  dataString(isnan(data)) = {'NaN'};
  
  % create table
  datatable = array2table(dataString);
  datatable.Properties.RowNames = [uniqueString(settings.methodStrings), {'Average'}];
  datatable.Properties.VariableNames = datanames;
  % delete old version
  if exist(fname, 'file')
    delete(fname)
  end
  % print table to file fname
  writetable(datatable, fname, 'WriteRowNames', true, 'Range', 'A2')
  % change first column name to 'Method'
  % writetable is used because xlswrite does not wort properly
  writetable(table({'Method'}), fname, 'WriteVariableNames', false, 'Range', 'A2')
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

function ms = methodString(method, strformat, settings)
% generates string in accordance with method, its settings and mostly
% format of resulting table
%
% Input:
%   method    - method name | string
%   strformat - format of resulting file | {'txt', 'xls'}
%                 'txt' - text file string (shorter)
%                 'xls' - xls file string (full)
%   settings  - settings of method | struct
    
  if nargin < 2
    strformat = 'txt';
  end
  if nargin < 3 || isempty(settings)
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
          addms{end+1} = getSpecVal(ker, strformat);
        end
        % autoscaling
        auto = defopts(settings.svm, 'autoscale', []);
        if ~isempty(auto) && auto
          addms{end+1} = getSpecVal('autoscale_on', strformat);
        elseif ~isempty(auto) && ~auto
          addms{end+1} = getSpecVal('autoscale_off', strformat);
        end
      end
    % decision tree
    case 'tree'
      if isfield(settings, 'tree')
        if isfield(settings.tree, 'type')
          addms{end+1} = getSpecVal(settings.tree.type, strformat);
        end
        if isfield(settings.tree, 'crit')
          addms{end+1} = getSpecVal(settings.tree.crit, strformat);
        end
        if isnan(defopts(settings.tree, 'prune', []))
          addms{end+1} = getSpecVal('optimal', strformat);
        end
      end
    % random forest
    case 'rf'
      if isfield(settings, 'rf')
        if isfield(settings.rf, 'type') && strcmp(settings.rf.type, 'matlab')
          addms{end+1} = getSpecVal('matlab', strformat);
        end
        if isfield(settings.rf, 'TreeType')
          addms{end+1} = getSpecVal(settings.rf.TreeType, strformat);
        end
        if isfield(settings.rf, 'learning')
          addms{end+1} = getSpecVal(settings.rf.learning, strformat);
        end
      end
    % discriminant analyses
    case {'lda', 'qda'}
      if isfield(settings, 'implementation')
        addms{end+1} = getSpecVal(settings.implementation, strformat);
      end
  end
  
  % gridsearch
  if isfield(settings, 'gridsearch')
    addms{end+1} = 'grid';
  end
  
  % add extension to method name
  if isempty(addms)
    add = [];
  else
    add = [' - ', strjoin(addms, ', ')];
  end
  ms = [getSpecVal(method, strformat, true), add];
end

function val = getSpecVal(s, resFormat, method)
% Return special string value
%
% Input:
%   method - boolean
  
  if nargin < 3
    method = false;
  end  
    
  % format
  if strcmp(resFormat, 'txt')
    valStruct = txtValues();
  else
    valStruct = xlsValues();
  end
  
  % find value
  if isfield(valStruct, s)
    val = valStruct.(s);
  % otherwise use default function
  else
    if method
      val = valStruct.defMethod(s);
    else
      val = valStruct.defProp(s);
    end
  end
end

function val = txtValues()
% function for default set of txt values

  % default function
  val.defMethod = @(x) x;
  val.defProp   = @(x) x(1:3);
  val.knn = 'k-nn';
  val.matlab = 'mtl';
  val.prtools = 'prt';
  val.autoscale_on = 'on';
  val.autoscale_off = 'off';
end

function val = xlsValues()
% function for default set of txt values

  % default function
  val.defMethod = @(x) upper(x);
  val.defProp   = @(x) x;
  val.fisher = 'Fisher';
  val.nb = 'Naive Bayes';
  val.tree = 'Tree';
  val.autoscale_on = 'autoscale on';
  val.autoscale_off = 'autoscale off';
end

function str = uniqueString(str)
% changes cell-array of string to unique strings

  nStr = length(str);
  strID = cell2mat(cellfun(@(x) strcmp(x, str), str, 'UniformOutput', false)');

  for i = 1:nStr
    % find actual string
    actualID = find(strID(i, :));
    for aid = 2:length(actualID)
      str{actualID(aid)} = [str{i}, ' (', num2str(aid), ')'];
    end
    % delete all same string occurences
    strID(strID(i, :), strID(i, :)) = false;
  end

end