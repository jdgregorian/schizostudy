classdef ANNClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = ANNClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'ann';
      obj.settings.hiddenSizes = defopts(settings, 'hiddenSizes', []);
      obj.settings.trainFcn = defopts(settings, 'trainFcn', 'trainscg');
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function        
      obj.classifier = patternnet(obj.settings.hiddenSizes, obj.settings.trainFcn);
      obj.classifier.trainParam.showWindow = false;
      indLabels = ind2vec(trainingLabels'+1);
      obj.classifier = train(obj.classifier, trainingData', indLabels);
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using artificial neural network
      y = obj.classifier(testingData');
      y = (vec2ind(y) - 1)';
    end
    
  end
end