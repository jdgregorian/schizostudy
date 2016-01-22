classdef MRFClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = MRFClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'mrf';
      obj.settings.nTrees = defopts(settings, 'nTrees', 11);
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior', 'nTrees'});
      obj.classifier = TreeBagger(obj.settings.nTrees, trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using matlab random forest
      y = predict(obj.classifier, testingData);
    end
    
  end
end