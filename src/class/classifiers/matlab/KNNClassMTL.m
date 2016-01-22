classdef KNNClassMTL < MatlabClassifier
  properties
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end
  
  methods
    
    function obj = KNNClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'knn';
      obj.settings.k = defopts(settings, 'k', 1);
      obj.settings.distance = defopts(settings, 'distance', 'euclidean');
      obj.settings.rule = defopts(settings, 'rule', 'nearest');
    end
    
    function obj = trainClassifier(obj, ~, ~)
    % knn has no training function
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using knn
      y = knnclassify(testingData, trainingData, trainingLabels, ...
          obj.settings.k, ...
          obj.settings.distance, ...
          obj.settings.rule);
    end
    
  end
end