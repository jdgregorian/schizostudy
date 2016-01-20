classdef SVMClass < Classifier
  properties
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end
  
  methods
    
    function SVM = SVMClass(settings) %, trainingData, trainingLabels)
    % constructor
      SVM.method = 'svm';
      SVM.settings = settings;
      SVM.implementation = 'matlab';
      SVM.classifier = [];
      
      % TODO: make this work with trainClassifier
%       if nargin > 2
%         cellset = cellSettings(SVM.settings, {'gridsearch'});
%         SVM.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
%       else
%         warning('Not enough training variables. Classifier will not be trained.')
%         SVM.classifier = [];
%       end
    end
    
    function SVM = trainClassifier(SVM, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(SVM.settings, {'gridsearch'});
      SVM.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(SVM, testingData, ~, ~)
    % prediction using SVM
      y = svmclassify(SVM.classifier, testingData);
    end
    
  end
end