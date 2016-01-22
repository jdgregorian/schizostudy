classdef QDAClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = QDAClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'qda';
      obj.settings.type = defopts(obj.settings, 'type', 'quadratic');
      if all(~strcmpi(obj.settings.type, {'quadratic', 'diagquadratic'}))
        warning('Not possible matlab QDA settings. Switching to QDA type ''linear''...\n')
        obj.settings.type = 'quadratic';
      end
    end
    
    function obj = trainClassifier(obj, ~, ~)
    % QDA in Matlab implementation has no training function
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using QDA
      smallerClassSize = min([sum(trainingLabels), sum(~trainingLabels)]);
      if strcmpi(obj.settings.type, 'quadratic') && (smallerClassSize - 1 < size(trainingData, 2))
        fprintf(['QDA type ''quadratic'' would cause indefinite covariance ',...
                 'matrix in this case.\nSwitching to ''diagquadratic''...\n'])
        QDAtype = 'diagquadratic';
      else
        QDAtype = obj.settings.type;
      end
      y = classify(testingData, trainingData, trainingLabels, QDAtype);
    end
    
  end
end