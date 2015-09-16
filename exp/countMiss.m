function [sMiss, class] = countMiss(folder, trueClass)
% sMiss = countMiss(folder) sums misclassifications from results of FC 
% performance testing in 'folder' and divides it with number of files 
% resulting in misclassification rate vector 'sMiss'. The number of 
% subjects has to be the same in all files. In opposite case function 
% returns cell array of misclassifications.
%
% sMiss = countMiss(folder, trueClass) sums misclassifications using 
% vector of correct subject classes 'trueClass'. Should be used if 
% vector of correct predictions is not available in result files. If
% 'trueClass' is also not available, function returns empty variable.

  if nargin == 0
    help countMiss
    return
  end
  
  fileList = dir([folder, filesep, '*.mat']);
  nFiles = length(fileList);
  
  % loading data
  corrPred = cell(nFiles,1);
  class = cell(nFiles,1);

  for f = 1:nFiles
    variables = load([folder filesep fileList(f).name], 'class', 'correctPredictions');
    if isfield(variables, 'correctPredictions')
      corrPred{f} = variables.correctPredictions;
    end
    class{f} = variables.class;
  end
  
  % not all files contain vector with correct predictions -> use classes
  if any(cellfun(@isempty,corrPred))
    % has all results same length or trueClass is missing
    nSub = length(class{1}{1});
    sMiss = zeros(1, nSub);
    for f = 1:nFiles
      if ~all(nSub == cellfun(@length,class{f})) || nargin < 2
        sMiss = [];
        return
      end
    
      % missclassification rate for one file
      nIter = length(class{f});
      fileMiss = zeros(1,nSub);
      for i = 1:nIter
        fileMiss = fileMiss + (class{f}{i} ~= trueClass);
      end
      sMiss = sMiss + fileMiss/nIter;
    end
    
  % sum all correct predictions
  else
    % has all results same length?
    nSub = length(corrPred{1}{1});
    for f = 1:nFiles
      sMiss = corrPred;
      sMiss{f} = cellfun(@not, corrPred{f}, 'UniformOutput', false);
      differentLength = false;
      if ~all(nSub == cellfun(@length, corrPred{f}))
        differentLength = true;
      end
    end
    % if lengths differ return misclassification cell array
    if differentLength
      return
    else % continue with rate counting
      sMiss = zeros(1, nSub);
    end
    
    for f = 1:nFiles
      % misclassification rate for one file
      nIter = length(class{f});
      fileMiss = zeros(1,nSub);
      for i = 1:nIter
        fileMiss = fileMiss + ~corrPred{f}{i};
      end
      sMiss = sMiss + fileMiss/nIter;
    end
    
  end
  
  sMiss = sMiss/nFiles;
  
end
