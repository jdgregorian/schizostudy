classdef LLCClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = LLCClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'llc';
      
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
          warning('Logistic linear classifier do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      obj.classifier = mnrfit(trainingData, trainingLabels + 1);
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using LLC
      y = (arrayfun(@(x) (obj.classifier(1) + testingData(x,:)*obj.classifier(2:end)) < 0,...
             1:size(testingData,1)))';
    end
    
  end
end