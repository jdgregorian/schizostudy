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
    end
    
    function SVM = trainClassifier(SVM, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(SVM.settings);
      SVM.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(SVM, testingData, trainingData, trainingLabels)
    % prediction using SVM
      y = svmclassify(SVM.classifier, testingData);
    end
    
  end
end