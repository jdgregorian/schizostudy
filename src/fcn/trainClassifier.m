function trainedClassifier = trainClassifier(method, trainingData, trainingLabels, settings, cellset)
% trainedClassifier = trainClassifier(method, trainingData, 
% trainingLabels, settings) trains classifier specified in variables 
% 'method' and 'settings' on 'trainingData' with 'trainingLabels'.
% 
% Warning: 'settings' can be in different format - use prepareSettings
%          first
%
% See also:
%   prepareSettings

  trainedClassifier.method = method;
  trainedClassifier.settings = settings;

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

  % PRTools implementations
  if prt
    toolData = prdataset(trainingData, trainingLabels);
    if isempty(settings.prior)
      toolData.prior = [sum(~trainingLabels); sum(trainingLabels)]/length(trainingLabels);
    else
      toolData.prior = settings.prior;
    end
    switch method
      case 'dectree' % decision tree
        trainedClassifier.classifier = treec(toolData, settings.tree.crit, settings.tree.prune);

      case 'rf' % random forest
        if strcmpi(settings.forest.learning, 'bagging')
          prwarning off
          trainedClassifier.classifier = randomforestc(toolData, settings.forest.nTrees, settings.forest.N);
        else
          % eval solution is not optimal -> find better syntax
          eval(['trainedPRClassifier = adaboostc(toolData, treec, settings.forest.nTrees, ', settings.forest.rule, ');'])
        end

      case 'lda' % linear discriminant classifier
        trainedClassifier.classifier = ldc(toolData, settings.da.R, settings.da.S);

      case 'qda' % quadratic discriminant classifier
        trainedClassifier.classifier = qdc(toolData, settings.da.R, settings.da.S);

      case 'fisher' % Fisher's linear discriminant fisherc
        trainedClassifier.classifier = fisherc(toolData);

      case 'nb' % naive Bayes
        trainedClassifier.classifier = naivebc(toolData, gaussm);

      case 'llc' % logistic linear classifier
        trainedClassifier.classifier = loglc(toolData);

    end
  else % pure matlab implementations
    switch method
      case 'svm' % support vector machine classifier
        trainedClassifier.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
%         SVM = fitcsvm(trainingData, trainingLabels, cellset{:});

      case 'mrf' % matlab random forest
        trainedClassifier.classifier = TreeBagger(settings.forest.nTrees, trainingData, trainingLabels, cellset{:});

      case 'rf' % random forest
        trainedClassifier.classifier = RandomForest(trainingData, trainingLabels', settings.forest.nTrees, settings.forest);

      case 'lintree' % linear tree
        trainedClassifier.classifier = LinearTree(trainingData, trainingLabels', settings.tree);

      case 'svmtree' % SVM tree
        trainedClassifier.classifier = SVMTree(trainingData, trainingLabels', settings.tree);

      case 'mtltree' % matlab classification tree
        trainedClassifier.classifier = ClassificationTree.fit(trainingData, trainingLabels, cellset{:});

      case 'llc' % logistic linear classifier
        trainedClassifier.classifier = mnrfit(trainingData, trainingLabels + 1);

      case 'nb' % naive Bayes
        trainedClassifier.classifier = NaiveBayes.fit(trainingData, trainingLabels, cellset{:});

      case 'perc' % linear perceptron
        trainedClassifier.classifier = perceptron;
        trainedClassifier.classifier.trainParam.showWindow = false;
        trainedClassifier.classifier = train(trainedClassifier.classifier, trainingData', trainingLabels');

      case 'ann' % artificial neural networks
        trainedClassifier.classifier = patternnet(settings.ann.hiddenSizes, settings.ann.trainFcn);
        trainedClassifier.classifier.trainParam.showWindow = false;
        indLabels = ind2vec(trainingLabels'+1);
        trainedClassifier.classifier = train(trainedClassifier.classifier, trainingData', indLabels);

      case 'rbf' % radial basis function network
        indLabels = ind2vec(trainingLabels' + 1);
        trainedClassifier.classifier = newpnn(trainingData', indLabels, settings.rbf.spread);

    end
  end
end