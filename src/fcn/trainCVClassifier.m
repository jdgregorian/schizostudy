function trainedCVClassifier = trainCVClassifier(method, data, labels, settings)
% trainedCVClassifier = trainCVClassifier(method, trainingData, 
% trainingLabels, settings) trains cross-validated classifier according to
% settings.gridsearch.
%
% Gridsearch is implemented in a very primitive way. At each level points
% from the parameter space are layed out using linear/logaritmic scale. At
% each point is trained classifier with aproprite settings. Point with the
% best performance is the center point of the next level search.
%
% Example: 
%   Find linear SVM classifier in 3-level gridsearch using properties
%   'boxconstraint' and 'kktviolationlevel'. 'boxconstraint' bounds are 0.2
%   and 10, and 'kktviolationlevel' bounds are 0 and 0.99. Gridsearch will
%   use 5 points for 'boxconstraint' and 4 for 'kktviolationlevel'. Scale
%   at first level is logaritmic for 'boxconstraint' and at the rest is 
%   linear. Scale is linear for 'kktviolationlevel' at all levels.
%
%   settings.gridsearch.levels = 3;
%   settings.gridsearch.properties = {'boxconstraint', 'kktviolationlevel'};
%   settings.gridsearch.bounds = {[0.2, 10], [0, 0.99]};
%   settings.gridsearch.npoints = [5, 4]; 
%   settings.gridsearch.scaling = {{'log', 'lin', 'lin'},
%                                  {'lin', 'lin', 'lin'}};
% 
% Warning: 'settings' can be in different format - use prepareSettings
%          first
%
% See also:
%   trainClassifier, prepareSettings

  trainedCVClassifier.method = method;
  trainedCVClassifier.settings = settings;
  cellset = cellSettings(eval(['settings.', settingsStructName(method)]));
  
  if ~isfield(settings, 'gridsearch')
    warning('No gridsearch set. Running regular training.')
    trainedCVClassifier.classifier = trainClassifier(method, data, labels, settings, cellset);
  end

  % implementation settings
  settings.implementation = defopts(settings, 'implementation', 'matlab');
  % Fisher and decision tree are implemented only in PRTools
  if any(strcmpi(method, {'fisher', 'dectree'}))
    settings.implementation = 'prtools';
  end
  
  % prepare properties 
  CVProperties = defopts(settings.gridsearch, 'properties', {});
  if isempty(CVProperties)
    warning('No properties in gridsearch set. Running regular training.')
    trainedCVClassifier.classifier = trainClassifier(method, data, labels, settings, cellset);
  end
  
  nProperties = length(CVProperties);
  
  nLevels = defopts(settings.gridsearch, 'levels', 1);
  CVGridBounds = defopts(settings.gridsearch, 'bounds', mat2cell([zeros(nProperties,1), ones(nProperties,1)], ones(nProperties,1)));
  CVGridPoints = defopts(settings.gridsearch, 'npoints', ones(nProperties, 1)*11);
  CVGridPoints(CVGridPoints < 2) = 2;
  
  % spacing
  defScale = {'lin'};
  defScale = {defScale(ones(nLevels,1))};
  CVGridScaling = defopts(settings.gridsearch, 'scaling', defScale);
  if ~iscell(CVGridScaling{1})
    CVGridScaling = {CVGridScaling};
    CVGridScaling = CVGridScaling(ones(1, nProperties));
  end

  nCombinations = prod(CVGridPoints);
  gridSettings = cell(nCombinations, 1);
  for i = 1:nCombinations
    gridSettings{i} = settings;
  end
  
  % CV prepare
  Nsubjects = size(data, 1);
  kFold = defopts(settings.gridsearch, 'crossval', 5);
  if strcmpi(kFold, 'loo') || (kFold > Nsubjects)
    kFold = Nsubjects;
    CVindices = 1:Nsubjects;
  else
    CVindices = crossvalind('kfold', Nsubjects, kFold);
  end
  
  bestLevelSettings = cell(nLevels, 1);
  bestLevelPerformance = zeros(nLevels, 1);
  
  % level loop
  for l = 1:nLevels
    % prepare grid values
    gridValues = cell(nProperties, 1);
    for p = 1:nProperties
      if l == 1
        lb = CVGridBounds{p}(1);
        ub = CVGridBounds{p}(2);
      else
        gridValues{p} = gridScaling(lb, ub, CVGridScaling{p}{l}, CVGridPoints(p) + 2);
        lb = gridValues{p}(2);
        ub = gridValues{p}(end - 1);      
      end
      gridValues{p} = gridScaling(lb, ub, CVGridScaling{p}{l}, CVGridPoints(p));
    end    

    % prepare settings
    for i = 0:nCombinations - 1
      exactParamId = i; 
      % extract appropriate values
      for p = 1:nProperties
        ParamId = mod(exactParamId, CVGridPoints(p));
        eval(['gridSettings{i+1}.', settingsStructName(method), '.', CVProperties{p}, ' = ',num2str(gridValues{p}(ParamId+1)),';'])
        exactParamId = (exactParamId - ParamId) / CVGridPoints(p);
      end
    end

    % main training loop
    performance = zeros(nCombinations, 1);
    for s = 1:nCombinations
      fprintf('Gridsearch level %d, settings %d...\n', l, s)
      correctPredictions = false(Nsubjects, 1);
      for f = 1:kFold
        foldIds = f == CVindices;
        % training
        trainingData = data(~foldIds,:);
        trainingLabels = labels(~foldIds);
        actualcellset = cellSettings(eval(['gridSettings{s}.', settingsStructName(method)]));
        try
          actualClassifier = trainClassifier(method, trainingData, trainingLabels, gridSettings{s}, actualcellset);
          % testing
          testingData = data(foldIds,:);
          testingLabels = labels(foldIds);
          y = classifierPredict(actualClassifier, testingData, trainingData, trainingLabels);
          % output check
          if iscell(y)
            if length(y) == 1
              y = str2double(y{1});
            else
              y = str2double(y);
            end
          end
          correctPredictions(foldIds) = y == testingLabels;
        catch err
          fprintf('%s\n', err.message)
          % if error continue
        end
      end
      performance(s) = sum(correctPredictions)/Nsubjects;
    end
    
    [bestLevelPerformance(l), bestSettingsID] = max(performance); 
    bestLevelSettings{l} = gridSettings{bestSettingsID};
    
    % calculate new bounds
    lowerID = bestSettingsID - 1; % TODO: non-primitive gridsearch
    for p = 1:nProperties
      ParamId = mod(lowerID, CVGridPoints(p));
      if ParamId == 0
        % boundary value
        lb = gridValues{p}(ParamId + 1);
      else
        % non-boundary value
        lb = gridValues{p}(ParamId);
      end
      if ParamId + 2 == CVGridPoints(p)
        % boundary value
        ub = gridValues{p}(ParamId + 1);
      else
        % non-boundary value
        ub = gridValues{p}(ParamId + 2);
      end
      lowerID = (lowerID - ParamId) / CVGridPoints(p);
    end

  end
  
  % train the best classifier settings
  [~, bestSettingsID] = max(bestLevelPerformance); 
  bestCellSettings = cellSettings(eval(['bestLevelSettings{bestSettingsID}.', settingsStructName(method)]));
  trainedCVClassifier = trainClassifier(method, data, labels, bestLevelSettings{bestSettingsID}, bestCellSettings);
  
end

function s = gridScaling(lb, ub, scaling, nPoints)
% Function returns 'nPoints' using 'scaling' from interval [lb, ub]
%
% Input:
%   lb      - lower bound
%   ub      - upper bound
%   scaling - scaling type | 'lin', 'log'
%   nPoints - number of points to lay out

  if lb > ub
    h = lb;
    lb = ub;
    ub = h;
  end

  if strcmpi(scaling, 'log') 
    % NaN protection
    if lb < 0 && ub < 0
      protlb = abs(lb);
      protub = abs(ub);
    elseif lb <= 0
      protlb = eps;
      protub = ub - lb + eps;
    else
      protlb = lb;
      protub = ub;
    end
    s = logspace(log10(protlb), log10(protub), nPoints);
    % return original scaling
    if lb < 0 && ub < 0
      s = -s;
    elseif lb <= 0
      s = s + lb - eps;
      s(1) = lb;
      s(end) = ub;
    end
  else
    s = linspace(lb, ub, nPoints);
  end
  
end