classdef FisherClassPRT < PRToolsClassifier
% Fisher's linear discriminant based classifier using PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = FisherClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'fisher';
      
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
        warning('Fisher''s linear discriminant (PRTools) do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = fisherc(toolData);
    end
    
  end
end