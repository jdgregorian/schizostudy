classdef (Abstract) MatlabClassifier < Classifier
  properties (Abstract)
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % implementation used for classifier
  end

  methods (Abstract)
    % training function
    obj = trainClassifier(obj, trainingData, trainingLabels)
    
    % prediction of classifier
    y = predict(obj, testingData, trainingData, trainingLabels)
  end

  methods
    
    function obj = MatlabClassifier(settings)
    % constructor
      obj = obj@Classifier(settings);
      obj.implementation = 'matlab';
    end
    
  end
  
end