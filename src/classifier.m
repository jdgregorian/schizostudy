function [performance, class, correctPredictions, errors, trainedClassifier] = ...
           classifier(method, data, labels, settings)
% Binary classification of data with labels by classifier chosen in method. 
% Returns performance of cross-validation of appropriate classifier.
%
% classifier() - shows help of classifier
% classifier(method, data, labels) - classify data with appropriate labels
%                                    using method
% classifier(method, data, labels, settings) - use additional settings
%                                              adjust classification
% [performance, class, correctPredictions, errors, trainedClassifier] = ...
%    classifier(...) - return classification performance, classes, correct 
%                      predictions of individual subjects, pertinent 
%                      errors of subsets, and trained classifiers on
%                      subsets
%
% Input:
%
%   method   - shortcut of the classifier type used | string
%              'ann'     - artificial neural network
%              'fisher'  - Fisher's linear discriminant fisherc (PRTools)
%              'knn'     - k-nearest neighbours
%              'lda'     - linear discriminant analysis
%              'llc'     - logistic linear classifier
%              'nb'      - naive Bayes
%              'perc'    - linear perceptron
%              'qda'     - quadratic discriminant analysis
%              'rbf'     - radial basis function network
%              'rda'     - regularized discriminant analysis (RDA 14)
%              'rf'      - random forest
%              'svm'     - support vector machine
%              'tree'    - decision tree
%   data     - input data matrix (rows - datapoints, columns - data 
%              dimension) or 1x2 cell array {training, testing} data 
%              | double matrix, cell array
%   labels   - class labels for each data or 1x2 cell array {training,
%              testing} labels | double vector, cell array
%   settings - structure of additional settings for classifier function
%
% Output:
%
%   performance        - classifiers performance | double
%   class              - classes assigned to individual subjects | double 
%                        vector
%   correctPredictions - correctness of classifications | boolean vector
%   errors             - errors of individual subsets | cell array of
%                        MException
%   trainedClassifier  - classifiers trained on individual subsets | cell
%                        array of Classifier class
%
% See Also:
%   classifyFC

  % default value
  performance = NaN;

  if nargin < 4
    settings = []; 
    if nargin < 3
      help classifier
      return
    end
  end
  
  % mode check
  trainTestMode = iscell(data) && iscell(labels);
  if trainTestMode
    % considering only two data matrices and two label vectors in cell
    % arrays
    trainSize = length(labels{1});
    data = [data{1}; data{2}];
    % transpone label vectors if necessary
    if size(labels{1}, 1) < size(labels{1}, 2)
      labels{1} = labels{1}';
    end
    if size(labels{2}, 1) < size(labels{2}, 2)
      labels{2} = labels{2}';
    end
    labels = [labels{1}; labels{2}];
  else
    trainSize = 0;
    if size(labels, 1) < size(labels, 2)
      labels = labels';
    end
  end
  
  % where the dimension reduction should be provided (in loop or out of the
  % cross-validation loop)
  if isfield(settings, 'dimReduction')
    dimRedInLoop = defopts(settings.dimReduction, 'inloop', false);
  else
    dimRedInLoop = false;
  end
  % dimension reduction outside the LOO loop
  if ~dimRedInLoop
    [data, settings] = reduceDim(data, labels, settings);
    settings.transformPrediction = false; % reduction is outside -> further 
                                          % transformation is not necessary
  end
  
  nSubjects = size(data, 1);
  
  % data scaling to zero mean and unit variance
  settings.autoscale = defopts(settings, 'autoscale', false);
  if settings.autoscale
    mx   = mean(data);
    stdx = std(data);
    data = (data-mx(ones(nSubjects,1),:))./stdx(ones(nSubjects,1),:);
  end

  if trainTestMode
    class = zeros(1, nSubjects - trainSize);
    correctPredictions = zeros(1, nSubjects - trainSize);
    kFold = 1;
    CVindices = [zeros(1,trainSize), ones(1,nSubjects - trainSize)];
  else % count cross-validation
    class = zeros(1, nSubjects);
    correctPredictions = zeros(1, nSubjects);
    kFold = defopts(settings, 'crossval', 'loo');
    % leave-one-out
    if strcmpi(kFold, 'loo') || (isnumeric(kFold) && (kFold > nSubjects))
      kFold = nSubjects;
      CVindices = 1:nSubjects;
    % leave-two-out
    elseif strcmpi(kFold, 'lto')
      if mod(nSubjects, 2)
        warning(['Number of subjects in leave-two-out cross-validation should be even.\n', ...
          'Odd number can lead to incorrect results.'])
      end
      kFold = ceil(nSubjects/2);
      CVindices = defopts(settings, 'pairing', ceil((1:nSubjects)/2));
    else
      CVindices = crossvalind('kfold', nSubjects, kFold);
    end
  end
  errors = cell(1, kFold);
  trainedClassifier = cell(1, kFold);
  
  % create classifier
  % the following line will be removed after unification of classifiers
  settings = prepareSettings(method, settings);
  
  TC = ClassifierFactory.createClassifier(method, defopts(settings, method, []));
  if isempty(TC)
    performance = NaN;
    class = NaN;
    correctPredictions = NaN;
    trainedClassifier = {};
    errors{1} = ['There is no ', method,' method in ', settings.implementation, ' implementation!'];
    return
  end
    
  % cross-validation loop
  for sub = 1:kFold
    
    foldIds = sub == CVindices;
    trainingData = data(~foldIds,:);
    trainingLabels = labels(~foldIds);
    
    % one error should not cancel full computation
    try

      % dimension reduction inside the loop
      if dimRedInLoop
        [trainingData, settings] = reduceDim(trainingData, trainingLabels, settings);
      end

      % training
      TC = TC.train(trainingData, trainingLabels);
      trainedClassifier{sub} = TC;

      % transform data if necessary (automatically disabled in outside
      % transformation)
      if settings.transformPrediction
        if isvector(settings.dimReduction.transMatrix)
          testingData = data(foldIds, settings.dimReduction.transMatrix);
        else
          testingData = data(foldIds, :)*settings.dimReduction.transMatrix;
        end
      else
        testingData = data(foldIds, :);
      end
      testingLabels = labels(foldIds);

      % prediction
      y = TC.predict(testingData, trainingData, trainingLabels);
      
      % return numeric output
      if iscell(y)
        if length(y) == 1
          y = str2double(y{1});
        else
          y = str2double(y);
        end
      end
      
      % return class predictions
      if trainTestMode
        correctPredictions = y == testingLabels;
        class = y;
      else
        correctPredictions(foldIds) = y == testingLabels;
        class(foldIds) = y;
      end
      
    % catch error not to cancel the whole computation
    catch err
      errors{sub} = err;
      class(foldIds) = NaN;
      fprintf('Subset %d could not be classified because of internal error.\n', sub)
    end
    
    if ~trainTestMode
      fprintf('Subset %d/%d done. Actual performance: %.2f%% \n', sub, kFold, sum(correctPredictions)/sum(sub >= CVindices)*100);
    end
  end
  
  % overall performance of classifier
  performance = sum(correctPredictions)/(nSubjects-trainSize);
 
end

function [reducedData, settings] = reduceDim(data, indices, settings)
% function for dimension reduction specified in settings

  if iscell(data) && iscell(indices)
    nDatasets = length(data);
    dataId = cellfun(@length, indices); % remember sizes of data
    dataId = arrayfun(@(x) x*ones(dataId(x), 1), 1:nDatasets, 'UniformOutput', false);
    dataId = cat(1, dataId{:});
    cData = cat(1, data{:});
    cIndices = cat(1, indices{:});
  else
    cData = data;
    cIndices = indices;
  end
  
  [Nsubjects, dim] = size(cData);
  
  % dimension reduction
  defSet.name = 'none';
  settings.dimReduction = defopts(settings, 'dimReduction', defSet);
  settings.dimReduction.name = defopts(settings.dimReduction, 'name', defSet.name);
  settings.transformPrediction = true;
  nDim = defopts(settings.dimReduction, 'nDim', dim);
  if nDim > dim
    nDim = dim;  % maximum of chosen dimensions
  end
  
  switch lower(settings.dimReduction.name)
    case 'none'
      % no dimension reduction 
      reducedData = data;
      settings.transformPrediction = false;
      return
      
    case 'pca'
      % principle component analysis feature reduction
      fprintf('Starting dimension reduction by PCA...\n')
      [reducedData, settings.dimReduction.transMatrix] = pcaReduction(cData, nDim);
      
    case 'kendall'
      % Kendall tau rank coefficient feature reduction
      fprintf('Starting dimension reduction using Kendall tau rank coefficients...\n')
      % minimal Kendall tau rank value
      treshold = defopts(settings.dimReduction, 'treshold', -1);
      [reducedData, settings.dimReduction.transMatrix] = kendallReduction(cData, cIndices, nDim, treshold);
      
    case 'ttest'
      % t-test feature reduction
      fprintf('Starting dimension reduction using t-test...\n')
      % significance level
      alpha = defopts(settings.dimReduction, 'alpha', 0.05);
      [reducedData, settings.dimReduction.transMatrix] = ttestReduction(cData, cIndices, nDim, alpha);
    
    case 'median'
      % feature reduction based on median (Honza Kalina's suggestion)
      fprintf('Starting dimension reduction using median difference coefficients...\n')
      nOnes = sum(cIndices);
      nZeros = Nsubjects - nOnes;
      % minimum number of differences
      minDif = defopts(settings.dimReduction, 'minDif', 2*abs(nOnes-nZeros));
      [reducedData, settings.dimReduction.transMatrix] = medianReduction(cData, cIndices, nDim, minDif);
      
    case 'hmean'
      % feature reduction based on highest mean
      fprintf('Starting dimension reduction using highest mean...\n')
      % minimal value of mean
      minVal = defopts(settings.dimReduction, 'minVal', 0);
      [reducedData, settings.dimReduction.transMatrix] = hMeanReduction(cData, nDim, minVal);
      
    otherwise
      error('Wrong dimReduction property name!!!')
      
  end
  
  fprintf('Dimension reduced from %d to %d\n', dim, size(reducedData, 2))
  
  if exist('dataId', 'var')
    redData = reducedData;
    reducedData = cell(1, nDatasets);
    for i = 1:nDatasets
      reducedData{i} = redData(i == dataId, :);
    end
  end

end

function settings = prepareSettings(method, settings)
% Prepares settings for main loop.
  
  settings.method = method;
  
  % prior settings
  if ~isfield(settings, 'prior')
    settings.(method).prior = [0.5, 0.5];
  end

  % implementation settings
  settings.(method).implementation = defopts(settings, 'implementation', 'matlab');
  % Fisher is implemented only in PRTools
  if any(strcmpi(method, {'fisher'}))
    settings.fisher.implementation = 'prtools';
  end
  
  % gridsearch settings
  settings.(method).gridsearch = defopts(settings, 'gridsearch', []);
  settings.(method).gridsearch.mode = defopts(settings.(method).gridsearch, 'mode', 'none');
  settings.(method).gridsearch.properties = defopts(settings.(method).gridsearch, 'properties', {});
end
