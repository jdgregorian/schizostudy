function y = classifierPredict(trainedClassifier, testingData, trainingData, trainingLabels)
% Classifies 'testingData' using 'trainedClassifier' trained by
% trainClassifier.
%
% See Also:
%   trainClassifier, prepareSettings

  % PRTools implementation
  if any(strcmpi(trainedClassifier.settings.implementation, {'prtools', 'prt'})) 
    toolTestingData = prdataset(testingData);
    y = toolTestingData*trainedClassifier.classifier*labeld;

  else % pure matlab implementation
    switch trainedClassifier.method
      case 'svm' % support vector machine classifier
        y = svmclassify(trainedClassifier.classifier, testingData);
%         y = predict(SVM,transData);

      case {'rf', 'mrf', 'lintree', 'svmtree', 'mtltree'} % tree based methods
        y = predict(trainedClassifier.classifier, testingData);

      case 'nb' % naive Bayes
        y = predict(trainedClassifier.classifier, testingData);

      case 'knn' % k-nearest neighbours
        y = knnclassify(testingData, trainingData, trainingLabels, ...
          trainedClassifier.settings.knn.k, ...
          trainedClassifier.settings.knn.distance, ...
          trainedClassifier.settings.knn.rule);

      case 'llc' % logistic linear classifier
        y = (arrayfun(@(x) (trainedClassifier.classifier(1) + testingData(x,:)*trainedClassifier.classifier(2:end)) < 0,...
             1:size(testingData,1)))';

      case 'lda' % linear discriminant analysis
        if strcmpi(trainedClassifier.settings.lda.type, 'linear') && (size(trainingData, 1) - 2 < size(trainingData, 2))
          fprintf(['LDA type ''linear'' would cause indefinite covariance ',...
                   'matrix in this case.\nSwitching to ''diaglinear''...\n'])
          LDAtype = 'diaglinear';
        else
          LDAtype = trainedClassifier.settings.lda.type;
        end
        y = classify(testingData, trainingData, trainingLabels, LDAtype);

      case 'qda' % quadratic discriminant analysis
        smallerClassSize = min([sum(trainingLabels), sum(~trainingLabels)]);
        if strcmpi(trainedClassifier.settings.qda.type, 'quadratic') && (smallerClassSize - 1 < size(trainingData, 2))
          fprintf(['QDA type ''quadratic'' would cause indefinite covariance ',...
                   'matrix in this case.\nSwitching to ''diagquadratic''...\n'])
          QDAtype = 'diagquadratic';
        else
          QDAtype = trainedClassifier.settings.qda.type;
        end
        y = classify(testingData, trainingData, trainingLabels, QDAtype);

      case 'rda' % regularized discriminant analysis (RDA 14)
        y = rda(trainingData, trainingLabels, testingData, trainedClassifier.settings.rda.alpha);

      case 'perc' % linear perceptron
        y = (trainedClassifier.classifier(testingData'))';

      case 'ann' % artificial neural networks
        y = trainedClassifier.classifier(testingData');
        y = (vec2ind(y) - 1)';
%           y = round(y);

      case 'rbf' % radial basis function network
        y = sim(trainedClassifier.classifier, testingData');
        y = (vec2ind(y)-1)';

      otherwise
        error('Wrong setting of method or implementation!!!\n')
    end
  end

end