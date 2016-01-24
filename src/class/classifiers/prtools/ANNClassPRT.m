classdef ANNClassPRT < PRToolsClassifier
% Automatic artificial neural network (neurc) based classifier using 
% PRTools
  properties    
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = ANNClassPRT(settings)
    % constructor
      obj = obj@PRToolsClassifier(settings);
      obj.method = 'ann';
      
      cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'prior'});
      if ~isempty(cellset)
        warning('Automatic artificial neural network classifier (PRTools) do not accept additional settings.')
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      toolData = obj.prdata(trainingData, trainingLabels);
      obj.classifier = neurc(toolData);
    end
    
  end
end