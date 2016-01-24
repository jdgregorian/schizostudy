classdef RBFClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = RBFClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'rbf';
      obj.settings.spread = defopts(settings, 'spread', 0.1);
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function        
      indLabels = ind2vec(trainingLabels' + 1);
      obj.classifier = newpnn(trainingData', indLabels, obj.settings.spread);
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using radial basis function network
      y = sim(obj.classifier, testingData');
      y = (vec2ind(y)-1)';
    end
    
  end
end