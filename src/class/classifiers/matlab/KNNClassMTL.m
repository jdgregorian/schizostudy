classdef KNNClassMTL < MatlabClassifier
% KNN classifier using default Matlab implementation

  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % implementation used for classifier
  end
  
  methods
    
    function obj = KNNClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'knn';
      obj.settings.k = defopts(settings, 'k', 1);
      obj.settings.distance = defopts(settings, 'distance', 'euclidean');
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % knn training function
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior', 'k', 'distance'});
      obj.classifier = fitcknn(trainingData, trainingLabels, ...
                               'NumNeighbors', obj.settings.k, ...
                               'Distance', obj.settings.distance, ...
                               cellset{:});
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using knn
      y = obj.classifier.predict(testingData);
    end
    
  end
end