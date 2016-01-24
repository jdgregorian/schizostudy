classdef NBClassPRT < PRToolsClassifier
% Naive Bayes classifier using PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = NBClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'nb';
      
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
        warning('Naive Bayes (PRTools) do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = naivebc(toolData, gaussm);
    end
    
  end
end