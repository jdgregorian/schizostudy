classdef PercClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = PercClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'perc';

      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
        warning('Linear perceptron do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      obj.classifier = perceptron;
      obj.classifier.trainParam.showWindow = false;
      obj.classifier = train(obj.classifier, trainingData', trainingLabels');
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using linear perceptron
      y = (obj.classifier(testingData'))';
    end
    
  end
end