classdef LDAClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = LDAClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'lda';
      obj.settings.type = defopts(obj.settings, 'type', 'linear');
      if all(~strcmpi(obj.settings.type, {'linear', 'diaglinear'}))
        warning('Not possible matlab LDA settings. Switching to LDA type ''linear''...\n')
        obj.settings.type = 'linear';
      end
    end
    
    function obj = trainClassifier(obj, ~, ~)
    % LDA in Matlab implementation has no training function
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using LDA
      if strcmpi(obj.settings.type, 'linear') && (size(trainingData, 1) - 2 < size(trainingData, 2))
        fprintf(['LDA type ''linear'' would cause indefinite covariance ',...
                 'matrix in this case.\nSwitching to ''diaglinear''...\n'])
        LDAtype = 'diaglinear';
      else
        LDAtype = obj.settings.type;
      end
      y = classify(testingData, trainingData, trainingLabels, LDAtype);
    end
    
  end
end