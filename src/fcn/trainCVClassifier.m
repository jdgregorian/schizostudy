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
  
  CVGridBounds = defopts(settings.gridsearch, 'bounds', mat2cell([zeros(nProperties,1), ones(nProperties,1)], ones(nProperties,1)));
  CVGridPoints = defopts(settings.gridsearch, 'npoints', ones(nProperties, 1)*11);
  CVGridPoints(CVGridPoints < 2) = 2;
  
  % prepare grid values
  gridValues = cell(nProperties, 1);
  for p = 1:nProperties
    gridValues{p} = linspace(CVGridBounds{p}(1), CVGridBounds{p}(2), CVGridPoints(p));
  end
  
  % prepare settings
  nCombinations = prod(CVGridPoints);
  gridSettings = cell(nCombinations, 1);
  for i = 1:nCombinations
    gridSettings{i} = settings;
  end
  for i = 0:nCombinations - 1
    exactParamId = i; 
    % extract appropriate values
    for j = 1:nProperties
      ParamId = mod(exactParamId, CVGridPoints(j));
      eval(['gridSettings{i+1}.', settingsStructName(method), '.', CVProperties{j}, ' = ',num2str(gridValues{j}(ParamId+1)),';'])
      exactParamId = (exactParamId - ParamId) / CVGridPoints(j);
    end
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
  
  % main training loop
  performance = zeros(nCombinations, 1);
  for s = 1:nCombinations
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
      catch
        % if error continue
      end
    end
    performance(s) = sum(correctPredictions)/Nsubjects;
  end
  
  % train the best classifier settings
  [~, bestSettingsID] = max(performance); 
  trainedCVClassifier.settings = gridSettings{bestSettingsID};
  bestCellSettings = cellSettings(eval(['gridSettings{bestSettingsID}.', settingsStructName(method)]));
  trainedCVClassifier.classifier = trainClassifier(method, data, labels, gridSettings{bestSettingsID}, bestCellSettings);
  
end