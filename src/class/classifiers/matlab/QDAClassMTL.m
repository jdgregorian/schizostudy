classdef QDAClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
  end
  
  methods
    
    function obj = QDAClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'qda';
      obj.settings.type = defopts(obj.settings, 'type', 'quadratic');
      % matlab discriminant type setting is more important
      obj.settings.type = defopts(obj.settings, 'DiscrimType', obj.settings.type);
      
      if verLessThan('matlab', '8.6')
        qdaType = {'quadratic', 'diagquadratic'};
      else
        qdaType = {'quadratic', 'diagquadratic', 'pseudoquadratic'};
      end
      if all(~strcmpi(obj.settings.type, qdaType))
        warning('Not possible matlab QDA settings. Switching to QDA type ''quadratic''...')
        obj.settings.type = 'quadratic';
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % QDA in Matlab implementation has no training function
      if ~verLessThan('matlab', '8.6')
        QDAtype = QDAClassMTL.indefQDACheck(obj.settings.type, trainingData, trainingLabels);
        cellset = cellSettings(obj.settings, {'gridsearch', 'implementation', 'type'});
        obj.classifier = fitcdiscr(trainingData, trainingLabels, ...
                                   'DiscrimType', QDAtype, ...
                                   cellset{:});
      end
    end
    
    function y = predict(obj, testingData, trainingData, trainingLabels)
    % prediction using QDA
    
      % older version
      if verLessThan('matlab', '8.6')
        QDAtype = QDAClassMTL.indefQDACheck(obj.settings.type, trainingData, trainingLabels);
        y = classify(testingData, trainingData, trainingLabels, QDAtype);
      else
        y = obj.classifier.predict(testingData);
      end
    end
    
  end
  
  methods (Static)
    
    function newType = indefQDACheck(type, trainingData, trainingLabels)
    % function checks if the training set is large enough and will not
    % cause indefiniteness of matrices in current QDA type settings
      smallerClassSize = min([sum(trainingLabels), sum(~trainingLabels)]);
      if strcmpi(type, 'quadratic') && (smallerClassSize - 1 < size(trainingData, 2))
        fprintf(['QDA type ''quadratic'' would cause indefinite covariance ',...
                 'matrix in this case.\nSwitching to ''diagquadratic''...\n'])
        newType = 'diagquadratic';
      else
        newType = type;
      end
    end
    
  end
end