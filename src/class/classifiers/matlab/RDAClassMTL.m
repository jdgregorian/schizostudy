classdef RDAClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = RDAClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'rda';
      obj.settings.alpha = defopts(settings, 'alpha', 0.999999);
    end
    
    function obj = trainClassifier(obj, ~, ~)
    % RDA has no training function
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using RDA (RDA 14)
      y = rda(trainingData, trainingLabels, testingData, obj.settings.alpha);
    end
    
  end
end