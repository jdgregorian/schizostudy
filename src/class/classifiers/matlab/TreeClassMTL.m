classdef TreeClassMTL < MatlabClassifier
% Decision tree classifier using Matlab implementations
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = TreeClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'tree';
      
      obj.settings.type = defopts(settings, 'type', 'linear');
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      switch obj.settings.type
        % linear tree
        case {'linear', 'lin', 'lintree'} 
          obj.classifier = LinearTree(trainingData, trainingLabels', obj.settings);
        % SVM tree
        case {'svm', 'svmtree'} 
          obj.classifier = SVMTree(trainingData, trainingLabels', obj.settings);
        % matlab classification tree
        case {'matlab', 'mtl', 'mtltree'} 
          cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior', 'type'});
          obj.classifier = ClassificationTree.fit(trainingData, trainingLabels, cellset{:});
      end
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using decision tree
      y = predict(obj.classifier, testingData);
    end
    
  end
end