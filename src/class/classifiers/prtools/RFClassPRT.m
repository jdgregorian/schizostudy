classdef RFClassPRT < PRToolsClassifier
% Random forest (randomforestc or adaboostc) classifier using PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = RFClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'rf';
      
      obj.settings.nTrees = defopts(settings, 'nTrees', 11);
      obj.settings.N = defopts(settings, 'N', 1);
      obj.settings.learning = defopts(settings, 'learning', 'bagging');
      obj.settings.rule = defopts(settings, 'rule', 'wvotec');
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);      
      if strcmpi(obj.settings.learning, 'bagging')
        prwarning off
        obj.classifier = randomforestc(toolData, obj.settings.nTrees, obj.settings.N);
      else
        % eval solution is not optimal -> find better syntax
        eval(['obj.classifier = adaboostc(toolData, treec, obj.settings.nTrees, ', obj.settings.rule, ');'])
      end
    end
    
  end
end