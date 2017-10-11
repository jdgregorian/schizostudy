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
      % matlab discriminant type setting is more important
      obj.settings.type = defopts(obj.settings, 'DiscrimType', obj.settings.type);
      
      if verLessThan('matlab', '8.6')
        ldaType = {'linear', 'diaglinear'};
      else
        ldaType = {'linear', 'diaglinear', 'pseudolinear'};
      end
      if all(~strcmpi(obj.settings.type, ldaType))
        warning('Not possible matlab LDA settings. Switching to LDA type ''linear''...')
        obj.settings.type = 'linear';
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
      % LDA in older Matlab implementations has no training function
      if ~verLessThan('matlab', '8.6')
        cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'type'});
        obj.classifier = fitcdiscr(trainingData, trainingLabels, ...
                                   'DiscrimType', obj.settings.type, ...
                                   cellset{:});
      end
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using LDA
    
      % older version
      if verLessThan('matlab', '8.6')
        if strcmpi(obj.settings.type, 'linear') && (size(trainingData, 1) - 2 < size(trainingData, 2))
          fprintf(['LDA type ''linear'' would cause indefinite covariance ',...
                   'matrix in this case.\nSwitching to ''diaglinear''...\n'])
          LDAtype = 'diaglinear';
        else
          LDAtype = obj.settings.type;
        end
        y = classify(testingData, trainingData, trainingLabels, LDAtype);
      else
        y = obj.classifier.predict(testingData);
      end
    end
    
  end
end