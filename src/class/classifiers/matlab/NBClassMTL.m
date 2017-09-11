classdef NBClassMTL < MatlabClassifier
% Naive Bayes classifier using default Matlab implementation

  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = NBClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'nb';
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      obj.classifier = fitcnb(trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using Naive Bayes classification
      y = predict(obj.classifier, testingData);
    end
    
  end
end