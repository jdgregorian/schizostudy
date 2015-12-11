function trainedCVClassifier = trainCVClassifier(method, data, labels, settings)
% trainedCVClassifier = trainCVClassifier(method, trainingData, 
% trainingLabels, settings) trains cross-validated classifier according to
% settings.gridsearch.
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
  defSpace = {'lin'};
  defSpace = {defSpace(ones(nLevels,1))};
  defSpace = defSpace(ones(1, nProperties));
  CVGridSpacing = defopts(settings.gridsearch, 'spacing', defSpace);

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
      if strcmpi(CVGridSpacing{p}{l}, 'log')
        gridValues{p} = logspace(log10(CVGridBounds{p}(1)), log10(CVGridBounds{p}(2)), CVGridPoints(p));
      else
        gridValues{p} = linspace(CVGridBounds{p}(1), CVGridBounds{p}(2), CVGridPoints(p));
      end
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
    lowerID = bestSettingsID - 1;
    for p = 1:nProperties
      ParamId = mod(lowerID, CVGridPoints(p));
      % TODO: calculation of bounds according to gridValues{p}(ParamId+1)
      lowerID = (lowerID - ParamId) / CVGridPoints(p);
    end

  end
  
  % train the best classifier settings
  [~, bestSettingsID] = max(bestLevelPerformance); 
  bestCellSettings = cellSettings(eval(['bestLevelSettings{bestSettingsID}.', settingsStructName(method)]));
  trainedCVClassifier = trainClassifier(method, data, labels, bestLevelSettings{bestSettingsID}, bestCellSettings);
  
end