classdef MRFClass < Classifier
  properties
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end
  
  methods
    
    function MRF = MRFClass(settings) %, trainingData, trainingLabels)
    % constructor
      MRF.method = 'mrf';
      settings.nTrees = defopts(settings, 'nTrees', 11);
      MRF.settings = settings;
      MRF.implementation = 'matlab';
      MRF.classifier = [];
      
      % TODO: make this work with trainClassifier
%       if nargin > 2
%         cellset = cellSettings(MRF.settings, {'gridsearch'});
%         MRF.classifier = TreeBagger(settings.forest.nTrees, trainingData, trainingLabels, cellset{:});
%       else
%         warning('Not enough training variables. Classifier will not be trained.')
%         MRF.classifier = [];
%       end
    end
    
    function MRF = trainClassifier(MRF, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(MRF.settings, {'gridsearch', 'nTrees'});
      MRF.classifier = TreeBagger(MRF.settings.nTrees, trainingData, trainingLabels, cellset{:});
    end
    
    function y = predict(MRF, testingData, ~, ~)
    % prediction using matlab random forest
      y = predict(MRF.classifier, testingData);
    end
    
  end
end