function trainedCVClassifier = trainCVClassifier(method, trainingData, trainingLabels, settings, cellset)
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
  
  if ~isfield(settings, 'gridsearch')
    warning('No gridsearch set. Running regular training.')
    trainedCVClassifier.classifier = trainClassifier(method, trainingData, trainingLabels, settings, cellset);
  end

  % implementation settings
  settings.implementation = defopts(settings, 'implementation', 'matlab');
  % Fisher and decision tree are implemented only in PRTools
  if any(strcmpi(method, {'fisher', 'dectree'}))
    settings.implementation = 'prtools';
  end
  prt = any(strcmpi(settings.implementation, {'prtools', 'prt'}));

  if ~prt && ...
       any(strcmpi(method, {'mrf', 'mtltree', 'nb', 'svm'})) && ...
       isfield(settings, method) && ...
       ~isempty(fields(eval(['settings.', method]))) && ...
       isempty(cellset)
   
    warning('Settings are not in correct format! Using prepareSettings...')
    [settings, cellset] = prepareSettings(method, settings);
    assert(~isempty(settings), 'Classifier settings are not in correct format')
  end

  % CV prepare
  Nsubjects = size(trainingData, 1);
  kFold = defopts(settings.gridsearch, 'crossval', 5);
  if strcmpi(kFold, 'loo') || (kFold > Nsubjects)
    kFold = Nsubjects;
    CVindices = 1:Nsubjects;
  else
    CVindices = crossvalind('kfold', Nsubjects, kFold);
  end
  
  % prepare properties 
  CVProperties = defopts(settings.gridsearch, 'properties', {});
  if isempty(CVProperties)
    warning('No properties in gridsearch set. Running regular training.')
    trainedCVClassifier.classifier = trainClassifier(method, trainingData, trainingLabels, settings, cellset);
  end
  
  nProperties = length(CVProperties);
  
  CVGridBounds = defopts(settings.gridsearch, 'bounds', mat2cell([zeros(nProperties,1), ones(nProperties,1)], ones(nProperties,1)));
  CVGridPoints = defopts(settings.gridsearch, 'npoints', ones(nProperties, 1)*11);
  if CVGridPoints < 2
    CVGridPoints = 2;
  end
  
  gridValues = cell(nProperties, 1);
  for p = 1:nProperties
    gridValues{p} = linspace(CVGridBounds{p}(1), CVGridBounds{p}(2), CVGridPoints);
  end
  
  nCombinations = prod(CVGridPoints);
  gridSettings = cell(nCombinations, 1);
  % TODO: Continue with following row
  %gridSettings = cellfun( @(x) x = settings, gridSettings)
  for i = 0:nCombinations - 1
    exactParamId = i; 
    % extract appropriate values
    for j = 1:nProperties
      ParamId = mod(exactParamId, CVGridPoints(j));
      eval(['gridSettings{i+1}.', settingsStructName(method),' = ',num2str(gridValues{p}(ParamId+1)),';'])
      exactParamId = (exactParamId - ParamId) / CVGridPoints(j);
    end
  end

  
  % main training loop
  %
  % for each settings do
  %   for each fold do
  %     actualClass = trainClassifier(method, foldTrainingData, foldTrainingLabels, actualsettings, actualcellset);
  %     perf = measurePerformance(actualClass);
  %   end
  % end
  %
  % bestSettings = argmax(perf);
  %
  % trainedCVClassifier.classifier = trainClassifier(method, trainingData, trainingLabels, bestSettings, bestCellset);
  
end