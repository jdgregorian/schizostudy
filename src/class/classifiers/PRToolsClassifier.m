classdef (Abstract) PRToolsClassifier < Classifier
  properties (Abstract)
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end

  methods (Abstract)
    % training function
    obj = trainClassifier(obj, trainingData, trainingLabels)
  end

  methods
    
    function obj = PRToolsClassifier(settings)
    % constructor
      obj = obj@Classifier(settings);
      obj.implementation = 'prtools';
      prwaitbar off
    end
    
    function toolData = prdata(obj, trainingData, trainingLabels)
      toolData = prdataset(trainingData, trainingLabels);
      if isempty(obj.settings.prior)
        toolData.prior = [sum(~trainingLabels); sum(trainingLabels)]/length(trainingLabels);
      else
        toolData.prior = obj.settings.prior;
      end
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction function (same for all PRTools classifiers
      toolTestingData = prdataset(testingData);
      y = toolTestingData*obj.classifier*labeld;
    end

  end
  
end