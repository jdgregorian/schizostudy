classdef SVMClassMTL < MatlabClassifier
  properties
    method         % classifier method
    settings       % classifier settings
    classifier     % own classifier
    implementation % imlementation used for classifier
    
    versionSwitch  % version of MATLAB for switching to new SVM syntax
  end
  
  methods
    
    function obj = SVMClassMTL(settings)
    % constructor
      obj = obj@MatlabClassifier(settings);
      obj.method = 'svm';
      obj.versionSwitch = '9.4';
      if verLessThan('matlab', obj.versionSwitch)
        obj.settings.kernelfunc = defopts(obj.settings, 'kernelfunction', 'linear');
        obj.settings.kernelfunc = defopts(obj.settings, 'kernel_function', obj.settings.kernelfunc);
      else
        obj.settings.kernelfunc = defopts(obj.settings, 'kernel_function', 'linear');
        obj.settings.kernelfunc = defopts(obj.settings, 'kernelfunction', obj.settings.kernelfunc);
        if strcmpi(obj.settings.kernelfunc, 'quadratic')
          obj.settings.kernelfunc = 'polynomial';
          obj.settings.polynomialorder = 2;
        end
      end
    end
    
    function obj = trainClassifier(obj, trainingData, trainingLabels)
    % training function
      cellset = cellSettings(obj.settings, ...
                 {'gridsearch', 'implementation', 'prior', ...
                  'kernel_function', 'kernelfunction', 'kernelfunc'});
      if verLessThan('matlab', obj.versionSwitch)
        obj.classifier = svmtrain(trainingData, trainingLabels, ...
                                  'kernel_function', obj.settings.kernelfunc, ...
                                  cellset{:});
      else
        obj.classifier = fitcsvm(trainingData, trainingLabels, ...
                                 'kernelfunction', obj.settings.kernelfunc, ...
                                 cellset{:});
      end
    end
    
    function y = predict(obj, testingData, ~, ~)
    % prediction using SVM
      if verLessThan('matlab', obj.versionSwitch)
        y = svmclassify(obj.classifier, testingData);
      else
        y = predict(obj.classifier, testingData);
      end
    end
    
  end
end