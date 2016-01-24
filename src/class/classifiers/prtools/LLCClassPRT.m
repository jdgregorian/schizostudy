classdef LLCClassPRT < PRToolsClassifier
% Logistic linear classifier using PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = LLCClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'llc';
      
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
        warning('Logistic linear classifier (PRTools) do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = loglc(toolData);
    end
    
  end
end