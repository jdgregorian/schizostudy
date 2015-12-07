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
  
  % implementation settings
  settings.implementation = defopts(settings, 'implementation', 'matlab');
  % Fisher and decision tree are implemented only in PRTools
  if any(strcmpi(method, {'fisher', 'dectree'}))
    settings.implementation = 'prtools';
  end
  prt = any(strcmpi(settings.implementation, {'prtools', 'prt'}));
  
  % prior settings
  if ~isfield(settings, 'prior')
    settings.prior = [0.5, 0.5];
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
  if prt % PRTools implementations
    prwaitbar off
    switch method
      case 'dectree' % decision tree (treec)
        settings.tree = defopts(settings, 'tree', []);
        settings.tree.crit = defopts(settings.tree, 'crit', 'infcrit');
        settings.tree.prune = defopts(settings.tree, 'prune', 0);
        if settings.tree.prune < -1
          warning('This implementation does not support pruning level lower than -1. Switching to 0.')
          settings.tree.prune = 0;
        end
        
      case 'rf' % random forest (randomforestc or adaboostc)
        settings.forest = defopts(settings, 'forest', []);
        settings.forest.nTrees = defopts(settings.forest, 'nTrees', 11);
        settings.forest.N = defopts(settings.forest, 'N', 1);
        settings.forest.learning = defopts(settings.forest, 'learning', 'bagging');
        settings.forest.rule = defopts(settings.forest, 'rule', 'wvotec');
        
      case {'lda', 'qda'} % linear or quadratic discriminant classifier
        settings.da = defopts(settings, method, []);
        settings.da.R = defopts(settings.da, 'R', 0);
        settings.da.S = defopts(settings.da, 'S', 0);
        
      case 'fisher' % Fisher's linear discriminant (fisherc)
        if isfield(settings,'fisher')
          warning('Fisher''s linear discriminant (PRTools) do not accept additional settings.')
        end
        
      case 'nb' % naive Bayes
        if isfield(settings,'nb')
          warning('Naive Bayes (PRTools) do not accept additional settings.')
        end
        
      case 'llc' % logistic linear classifier (loglc)
        if isfield(settings,'llc')
          warning('Logistic linear classifier (PRTools) do not accept additional settings.')
        end
        
      otherwise
        warning('There is no %s method from PRTools implemented!', method)
        performance = NaN;
        class = NaN;
        correctPredictions = NaN;
        errors{1} = ['There is no ', method,' method from PRTools implemented!'];
        return
         
    end
  else %if any(strcmpi(settings.implementation, {'matlab', 'mtl'}))
    switch method
      case 'svm' % support vector machine
        settings.svm = defopts(settings, 'svm', []);
        cellset = cellSettings(settings.svm);

      case {'rf', 'mrf'} % forests
        settings.forest = defopts(settings, 'forest', []);
        % gain number of trees 
        settings.forest.nTrees = defopts(settings.forest, 'nTrees', 11);

        if strcmpi(method, 'mrf')
            cellset = cellSettings(settings.forest, {'nTrees'});
        end

      case {'lintree', 'mtltree', 'svmtree'} % trees
        settings.tree = defopts(settings, 'tree', []);

        if strcmpi(method, 'mtltree')
          cellset = cellSettings(settings.tree);
        end

      case 'nb' % naive Bayes
        settings.nb = defopts(settings, 'nb', []);
        settings.nb.prior = defopts(settings, 'prior', 'uniform');
        cellset = cellSettings(settings.nb);

      case 'knn' % k-nearest neighbours
        settings.knn = defopts(settings, 'knn', []);
        settings.knn.k = defopts(settings.knn, 'k', 1);
        settings.knn.distance = defopts(settings.knn, 'distance', 'euclidean');
        settings.knn.rule = defopts(settings.knn, 'rule', 'nearest');

      case 'llc' % logistic linear classifier
        if isfield(settings,'llc')
          warning('Logistic linear classifier do not accept additional settings.')
        end

      case 'lda' % linear discriminant analysis
        settings.lda = defopts(settings, 'lda', []);
        settings.lda.type = defopts(settings.lda, 'type', 'linear');
        if all(~strcmpi(settings.lda.type, {'linear', 'diaglinear'}))
          warning('Not possible matlab LDA settings. Switching to LDA type ''linear''...\n')
          settings.lda.type = 'linear';
        end
        
      case 'qda' % quadratic discriminant analysis
        settings.qda = defopts(settings, 'qda', []);
        settings.qda.type = defopts(settings.qda, 'type', 'quadratic');
        if all(~strcmpi(settings.qda.type, {'quadratic', 'diagquadratic'}))
          warning('Not possible matlab QDA settings. Switching to LDA type ''quadratic''...\n')
          settings.qda.type = 'quadratic';
        end
        
      case 'rda' % regularized discriminant analysis (RDA 14)
        settings.rda = defopts(settings, 'rda', []);
        settings.rda.alpha = defopts(settings.rda, 'alpha', 0.999999);
        
      case 'perc' % linear perceptron
        if isfield(settings,'perc')
          warning('Linear perceptron do not accept additional settings.')
        end

      case 'ann' % artificial neural network
        settings.ann = defopts(settings, 'ann', []);
        settings.ann.hiddenSizes = defopts(settings.ann, 'hiddenSizes', []);
        settings.ann.trainFcn = defopts(settings.ann, 'trainFcn', 'trainscg');
        
      case 'rbf' % radial basis function network
        settings.rbf = defopts(settings, 'rbf', []);
        settings.rbf.spread = defopts(settings.rbf, 'spread', 0.1);
        
    end
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
    if strcmpi(kFold,'loo') || (kFold > Nsubjects)
      kFold = Nsubjects;
      CVindices = 1:Nsubjects;
    else
      CVindices = crossvalind('kfold', Nsubjects, kFold);
    end
  end
    
  for sub = 1:kFold
    
    foldIds = sub == CVindices;
    trainingData = data(~foldIds,:);
    trainingLabels = labels(~foldIds);
    
    % dimension reduction inside the LOO loop
%     [trainingSet, settings] = reduceDim(trainingSet,settings);
    
    try % one error should not cancel full computation

      % training
      if prt % PRTools implementations
        toolData = prdataset(trainingData, trainingLabels);
        if isempty(settings.prior)
          toolData.prior = [sum(~trainingLabels); sum(trainingLabels)]/length(trainingLabels);
        else
          toolData.prior = settings.prior;
        end
        switch method
          case 'dectree' % decision tree
            trainedPRClassifier = treec(toolData, settings.tree.crit, settings.tree.prune);
%             getopt_pars
            
          case 'rf' % random forest
            if strcmpi(settings.forest.learning, 'bagging')
              prwarning off
              trainedPRClassifier = randomforestc(toolData, settings.forest.nTrees, settings.forest.N);
            else
              % eval solution is not optimal -> find better syntax
              eval(['trainedPRClassifier = adaboostc(toolData, treec, settings.forest.nTrees, ', settings.forest.rule, ');'])
            end
            
          case 'lda' % linear discriminant classifier
            trainedPRClassifier = ldc(toolData, settings.da.R, settings.da.S);
            
          case 'qda' % quadratic discriminant classifier
            trainedPRClassifier = qdc(toolData, settings.da.R, settings.da.S);
            
          case 'fisher' % Fisher's linear discriminant fisherc
            trainedPRClassifier = fisherc(toolData);
            
          case 'nb' % naive Bayes
            trainedPRClassifier = naivebc(toolData, gaussm);
            
          case 'llc' % logistic linear classifier
            trainedPRClassifier = loglc(toolData);
            
        end
      else % pure matlab implementations
        switch method
          case 'svm' % support vector machine classifier
            SVM = svmtrain(trainingData, trainingLabels, cellset{:});
    %         SVM = fitcsvm(trainingData, trainingLabels, cellset{:});

          case 'mrf' % matlab random forest
            Forest = TreeBagger(settings.forest.nTrees, trainingData, trainingLabels, cellset{:});

          case 'rf' % random forest
            Forest = RandomForest(trainingData, trainingLabels', settings.forest.nTrees, settings.forest);

          case 'lintree' % linear tree
            Forest = LinearTree(trainingData, trainingLabels', settings.tree);

          case 'svmtree' % SVM tree
            Forest = SVMTree(trainingData, trainingLabels', settings.tree);

          case 'mtltree' % matlab classification tree
            Forest = ClassificationTree.fit(trainingData, trainingLabels, cellset{:});

          case 'llc' % logistic linear classifier
            LLC = mnrfit(trainingData, trainingLabels + 1);

          case 'nb' % naive Bayes
            NB = NaiveBayes.fit(trainingData, trainingLabels, cellset{:});

          case 'perc' % linear perceptron
            net = perceptron;
            net.trainParam.showWindow = false;
            net = train(net, trainingData', trainingLabels');

          case 'ann' % artificial neural networks
            net = patternnet(settings.ann.hiddenSizes, settings.ann.trainFcn);
            net.trainParam.showWindow = false;
            indLabels = ind2vec(trainingLabels'+1);
            net = train(net, trainingData', indLabels);

          case 'rbf' % radial basis function network
            indLabels = ind2vec(trainingLabels' + 1);
            net = newpnn(trainingData', indLabels, settings.rbf.spread);
            
        end
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
      if prt % PRTools implementation
        toolTestingData = prdataset(testingData);
        y = toolTestingData*trainedPRClassifier*labeld;
           
      else % pure matlab implementation
        switch method
          case 'svm' % support vector machine classifier
            y = svmclassify(SVM, testingData);
    %         y = predict(SVM,transData);

          case {'rf', 'mrf', 'lintree', 'svmtree', 'mtltree'} % tree based methods
            y = predict(Forest, testingData);

          case 'nb' % naive Bayes
            y = predict(NB, testingData);

          case 'knn' % k-nearest neighbours
            y = knnclassify(testingData, trainingData, trainingLabels, ...
              settings.knn.k, settings.knn.distance, settings.knn.rule);

          case 'llc' % logistic linear classifier
            y = (arrayfun(@(x) (LLC(1) + testingData(x,:)*LLC(2:end)) < 0, 1:size(testingData,1)))';

          case 'lda' % linear discriminant analysis
            if strcmpi(settings.lda.type, 'linear') && (size(trainingData, 1) - 2 < size(trainingData, 2))
              fprintf(['LDA type ''linear'' would cause indefinite covariance ',...
                       'matrix in this case.\nSwitching to ''diaglinear''...\n'])
              LDAtype = 'diaglinear';
            else
              LDAtype = settings.lda.type;
            end
            y = classify(testingData, trainingData, trainingLabels, LDAtype);
            
          case 'qda' % quadratic discriminant analysis
            smallerClassSize = min([sum(trainingLabels), sum(~trainingLabels)]);
            if strcmpi(settings.qda.type, 'quadratic') && (smallerClassSize - 1 < size(trainingData, 2))
              fprintf(['QDA type ''quadratic'' would cause indefinite covariance ',...
                       'matrix in this case.\nSwitching to ''diagquadratic''...\n'])
              QDAtype = 'diagquadratic';
            else
              QDAtype = settings.qda.type;
            end
            y = classify(testingData, trainingData, trainingLabels, QDAtype);
            
          case 'rda' % regularized discriminant analysis (RDA 14)
            y = rda(trainingData, trainingLabels, testingData, settings.rda.alpha);

          case 'perc' % linear perceptron
            y = (net(testingData'))';

          case 'ann' % artificial neural networks
            y = net(testingData');
            y = (vec2ind(y) - 1)';
  %           y = round(y);

          case 'rbf' % radial basis function network
            y = sim(net, testingData');
            y = (vec2ind(y)-1)';

          otherwise
            fprintf('Wrong setting of method or implementation!!!\n')
            return
        end
      end
      
      if iscell(y)
        y = str2double(y{1});
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
    dataId = arrayfun(@(x) x*ones(dataId(x),1),1:nDatasets, 'UniformOutput', false);
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
