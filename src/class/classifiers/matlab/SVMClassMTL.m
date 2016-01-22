classdef SVMClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = SVMClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'svm';
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      obj.classifier = svmtrain(trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using SVM
      y = svmclassify(obj.classifier, testingData);
    end
    
  end
end