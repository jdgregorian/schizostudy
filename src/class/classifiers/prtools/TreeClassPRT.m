classdef TreeClassPRT < PRToolsClassifier
% Decision tree (treec) classifier using PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = TreeClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'tree';
      
      obj.settings.crit = defopts(settings, 'crit', 'infcrit');
      obj.settings.prune = defopts(settings, 'prune', 0);
      if obj.settings.prune < -1
        warning('This implementation does not support pruning level lower than -1. Switching to 0.')
        obj.settings.prune = 0;
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = treec(toolData, obj.settings.crit, obj.settings.prune);
    end
    
  end
end