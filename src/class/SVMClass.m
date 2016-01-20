classdef SVMClass < Classifier
  properties
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end
  
  methods
    
    function SVM = SVMClass(settings)
    % constructor
      SVM.method = 'svm';
      SVM.settings = settings;
      SVM.implementation = 'matlab';
      SVM.classifier = [];
      % TODO: make the following lines work
%       if nargin > 0
%         SVM = SVM.train(trainingData, trainingLabels);
%       else
%         warning('Not enough training variables. Classifier will not be trained.')
%       end
    end
    
    function SVM = trainClassifier(SVM, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(SVM.settings, {'gridsearch'});
      SVM.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(SVM, testingData, trainingData, trainingLabels)
    % prediction using SVM
      y = svmclassify(SVM.classifier, testingData);
    end
    
  end
end