classdef KNNClass < Classifier
  properties
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end
  
  methods
    
    function KNN = KNNClass(settings)
    % constructor
      KNN.method = 'knn';
      settings.k = defopts(settings, 'k', 1);
      settings.distance = defopts(settings, 'distance', 'euclidean');
      settings.rule = defopts(settings, 'rule', 'nearest');
      KNN.settings = settings;
      KNN.implementation = 'matlab';
      KNN.classifier = [];
    end
    
    function KNN = trainClassifier(KNN, ~, ~)
    % knn has no training function
    end
    
    function y = predict(KNN, testingData, trainingData, trainingLabels)
    % prediction using knn
      y = knnclassify(testingData, trainingData, trainingLabels, ...
          KNN.settings.k, ...
          KNN.settings.distance, ...
          KNN.settings.rule);
    end
    
  end
end