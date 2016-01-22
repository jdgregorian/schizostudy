function [performance, class, correctPredictions, errors] = classifier(method, data, labels, settings)
% Binary classification of data with labels by classifier chosen in method. 
% Returns performance of cross-validation of appropriate classifier.
%
% classifier() - shows help of classifier
% classifier(method, data, labels) - classify data with appropriate labels
%                                    using method
% classifier(method, data, labels, settings) - use additional settings
%                                              adjust classification
% [performance, class, correctPredictions, errors] = classifier(...)
%   - return classification performance, classes, correct predictions of
%   individual subjects and pertinent errors of subsets
%
% Input:
%
%   method   - shortcut of the classifier type used | string
%              'svm'     - support vector machine
%              'rf'      - random forest
%              'mrf'     - MATLAB random forest
%              'dectree' - decision tree (PRTools)
%              'lintree' - tree using linear distance based decision splits
%              'mtltree' - MATLAB classification tree
%              'svmtree' - tree using linear svm based decision splits
%              'nb'      - naive Bayes
%              'knn'     - k-nearest neighbours
%              'llc'     - logistic linear classifier
%              'lda'     - linear discriminant analysis
%              'qda'     - quadratic discriminant analysis
%              'rda'     - regularized discriminant analysis (RDA 14)
%              'fisher'  - Fisher's linear discriminant fisherc (PRTools)
%              'ann'     - artificial neural network
%              'rbf'     - radial basis function network
%              'perc'    - linear perceptron
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
%   class              - classes assigned to individual subjects ! double 
%                        vector
%   correctPredictions - correctness of classifications | boolean vector
%   errors             - errors of individual subsets | cell array of
%                       MException
%
% See Also:
%   classifyFC, trainClassifier, trainCVClassifier, classifierPredict, 
%   prepareSettings

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
  
  % settings before the main loop
  [settings, cellset] = prepareSettings(method, settings);
  if isempty(settings)
    warning('There is no %s method from PRTools implemented!', method)
    performance = NaN;
    class = NaN;
    correctPredictions = NaN;
    errors{1} = ['There is no ', method,' method from PRTools implemented!'];
    return
  end
  
  % dimension reduction outside the LOO loop
  [data, settings] = reduceDim(data, labels, settings);
  settings.transformPrediction = false; % reduction is outside -> further 
                                        % transformation is not necessary
  Nsubjects = size(data, 1);
  
  % data scaling to zero mean and unit variance
  settings.autoscale = defopts(settings, 'autoscale', false);
  if settings.autoscale
    mx   = mean(data);
    stdx = std(data);
    data = (data-mx(ones(Nsubjects,1),:))./stdx(ones(Nsubjects,1),:);
  end

  if trainTestMode
    class = zeros(1, Nsubjects - trainSize);
    correctPredictions = zeros(1, Nsubjects - trainSize);
    errors = cell(1);
    kFold = 1;
    CVindices = [zeros(1,trainSize), ones(1,Nsubjects - trainSize)];
  else % count cross-validation
    class = zeros(1, Nsubjects);
    correctPredictions = zeros(1, Nsubjects);
    errors = cell(1,Nsubjects);
    kFold = defopts(settings, 'crossval', 'loo');
    if strcmpi(kFold, 'loo') || (kFold > Nsubjects)
      kFold = Nsubjects;
      CVindices = 1:Nsubjects;
    else
      CVindices = crossvalind('kfold', Nsubjects, kFold);
    end
  end
  
  % create classifier
  % the following line will be removed after unification of classifiers
  settings.(settingsStructName(method)).gridsearch = settings.gridsearch;
  settings.(settingsStructName(method)).implementation = settings.implementation;
  
  TC = ClassifierFactory.createClassifier(method, defopts(settings, settingsStructName(method)));
    
  for sub = 1:kFold
    
    foldIds = sub == CVindices;
    trainingData = data(~foldIds,:);
    trainingLabels = labels(~foldIds);
    
    % dimension reduction inside the LOO loop
%     [trainingSet, settings] = reduceDim(trainingSet,settings);
    
    try % one error should not cancel full computation

      % training
      if strcmpi(settings.gridsearch.mode, 'none')
%         trainedClassifier = trainClassifier(method, trainingData, trainingLabels, settings, cellset);
        TC = TC.train(trainingData, trainingLabels);
      else
%         trainedClassifier = trainCVClassifier(method, trainingData, trainingLabels, settings);
        TC = TC.train(trainingData, trainingLabels);
      end

      % prediction
      % transform data if necessary (automatically disabled in outside
      % transformation)
      if settings.transformPrediction
        testingData = data(foldIds,:)*settings.dimReduction.transMatrix;
      else
        testingData = data(foldIds,:);
      end
      testingLabels = labels(foldIds);

      % predict according to the method
      y = TC.predict(testingData, trainingData, trainingLabels);
%       y = classifierPredict(trainedClassifier, testingData, trainingData, trainingLabels);
      
      if iscell(y)
        if length(y) == 1
          y = str2double(y{1});
        else
          y = str2double(y);
        end
      end
      
      if trainTestMode
        correctPredictions = y == testingLabels;
        class = y;
      else
        correctPredictions(foldIds) = y == testingLabels;
        class(foldIds) = y;
      end
      
    catch err
      errors{sub} = err;
      class(foldIds) = NaN;
      fprintf('Subset %d could not be classified because of internal error.\n', sub)
    end
    
    if ~trainTestMode
      fprintf('Subset %d/%d done. Actual performance: %.2f%% \n', sub, kFold, sum(correctPredictions)/sum(sub >= CVindices)*100);
    end
  end

  performance = sum(correctPredictions)/(Nsubjects-trainSize);
 
end

function [reducedData,settings] = reduceDim(data, indices, settings)
% function for dimension reduction specified in settings

  if iscell(data) && iscell(indices)
    nDatasets = length(data);
    dataId = cellfun(@length, indices); % remember sizes of data
    dataId = arrayfun(@(x) x*ones(dataId(x),1), 1:nDatasets, 'UniformOutput', false);
    dataId = cat(1, dataId{:});
    data = cat(1, data{:});
    indices = cat(1, indices{:});
  end
  
  [Nsubjects, dim] = size(data);
  
  % dimension reduction
  defSet.name = 'none';
  settings.dimReduction = defopts(settings, 'dimReduction', defSet);
  settings.dimReduction.name = defopts(settings.dimReduction, 'name', defSet.name);
  settings.transformPrediction = false;
  nDim = defopts(settings.dimReduction, 'nDim', dim);
  if nDim > dim
    nDim = dim;  % maximum of chosen dimensions
  end
  
  switch settings.dimReduction.name
    case 'pca'
      % principle compopnent analysis feature reduction
      fprintf('Starting dimension reduction by PCA...\n')
      if nDim > Nsubjects-1
        nDim = Nsubjects-1;
      end
      
      [settings.dimReduction.transMatrix, transData] = pca(data);
      nDim = min(size(transData,2), nDim);
      reducedData = transData(:,1:nDim);
      
      settings.transformPrediction = true;
      fprintf('Dimension reduced from %d to %d\n', dim, nDim)
      
    case 'kendall'
      % Kendall tau rank coefficient feature reduction
      % (according to Hui 2009)
      fprintf('Starting dimension reduction using Kendall tau rank coefficients...\n')
      treshold = defopts(settings.dimReduction, 'treshold', -1); % minimal Kendall tau rank value
      
      nOne = sum(indices);
      nZero = Nsubjects - nOne;
      nc = zeros(1,dim);
      % for each value from one group count equalities for each value from the
      % other
      for ind = 1:nZero
        for counterInd = nZero + 1:Nsubjects
          nc = nc + (sign(data(ind,:)-data(counterInd,:)) == true(1,dim)*sign(indices(ind)-indices(counterInd)));
        end
      end
      nd = ones(1,dim) * nOne * nZero - nc;
      tau = (nc - nd)/(nZero*nOne); % count Kendall tau ranks
      
      [sortedTau, tauId] = sort(abs(tau),'descend');
      reducedData = data(:,tauId(1:nDim)); % reduction by dimension setting
      reducedData = reducedData(:,sortedTau(1:nDim) > treshold); % reduction by treshold
      
      if isempty(reducedData) % check if some data left
        warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
        reducedData = data(:,tauId(1));
      end
      
      fprintf('Dimension reduced from %d to %d\n', dim, size(reducedData,2))
      
    case 'ttest'
      % t-test feature reduction
      fprintf('Starting dimension reduction using t-test...\n')
      alpha = defopts(settings.dimReduction, 'alpha', 0.05); % significance level
      
      [t2, p] = ttest2(data(logical(indices),:),data(~logical(indices),:),'Alpha',alpha, 'Vartype','unequal');
      
      reducedData = data(:,logical(t2)); % reduction by ttest

      if isempty(reducedData) % check if some data left
        warning('Too severe constraints! Preventing emptyness of reduced dataset by keeping one dimension with the greatest Kendall tau rank.')
        [~, pMinId] = min(p);
        reducedData = data(:,pMinId(1));
      elseif sum(t2) > nDim   % reduction by dimensions with the lowest p-values 
        [~, pId] = sort(p(logical(t2)));
        reducedData = reducedData(:,pId(1:nDim));
      end
      
      fprintf('Dimension reduced from %d to %d\n', dim, size(reducedData,2))
    
    case 'median'
      % feature reduction according to Honza Kalina's suggestion:
      %    Choose median value in each dimension, count how many
      %    individuals has greater or lower value
      fprintf('Starting dimension reduction using median difference coefficients...\n')
      nOnes = sum(indices);
      nZeros = Nsubjects - nOnes;
      minDif = defopts(settings.dimReduction, 'minDif', 2*abs(nOnes-nZeros)); % minimum number of differences
      
      medData = median(data,1);
      greaterSub = data > repmat(medData,Nsubjects,1);
      greaterOnes = sum(greaterSub & repmat(indices,1,dim),1);
      greaterZeros = sum(greaterSub & repmat(~indices,1,dim),1);
      % count median difference coefficient
      nDif = abs(greaterOnes - greaterZeros) + abs(nOnes - nZeros - greaterOnes + greaterZeros);
      
      reducedData = data(:,nDif >= minDif);
      redDim = size(reducedData,2);
      
      if redDim == 0 % check if some data left
        warning(['Too severe constraints! Preventing emptyness of reduced',...
          'dataset by keeping one dimension with the greatest difference coefficient.'])
        [~, minId] = min(nDif);
        reducedData = data(:, minId(1));
      elseif redDim > nDim   % reduction by dimensions with the greatest difference coefficients
        [~, difId] = sort(nDif(nDif >= minDif),'descend');
        reducedData = reducedData(:,difId(1:nDim));
      end
      
      fprintf('Dimension reduced from %d to %d\n', dim, redDim)
      
    case 'none'
      reducedData = data;
      
    otherwise
      error('Wrong dimReduction property name!!!')
      
  end
  
  if exist('dataId','var')
    redData = reducedData;
    reducedData = cell(1,nDatasets);
    for i = 1:nDatasets
      reducedData{i} = redData(i == dataId,:);
    end
  end

end
