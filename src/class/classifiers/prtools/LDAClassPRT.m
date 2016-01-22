classdef LDAClassPRT < PRToolsClassifier
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = LDAClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'lda';
      obj.settings.R = defopts(obj.settings, 'R', 0);
      obj.settings.S = defopts(obj.settings, 'S', 0);
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = ldc(toolData, obj.settings.R, obj.settings.S);
    end
    
  end
end