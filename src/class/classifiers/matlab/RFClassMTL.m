classdef RFClassMTL < MatlabClassifier
% Random forest classifier using Matlab implementations
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = RFClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'rf';
      
      % gain number of trees 
      obj.settings.nTrees = defopts(settings, 'nTrees', 11);
      obj.settings.type = defopts(settings, 'type', 'classic');
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      switch obj.settings.type
        % matlab random forest
        case {'matlab', 'mtl', 'mrf'}
          cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior', 'type', 'nTrees'});
          obj.classifier = TreeBagger(obj.settings.nTrees, trainingData, trainingLabels, cellset{:});
        % random forest
        case {'classic', 'rf'} %TODO: find more specific keyword
          obj.classifier = RandomForest(trainingData, trainingLabels', obj.settings.nTrees, obj.settings);
      end
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using random forest
      y = predict(obj.classifier, testingData);
    end
    
  end
end