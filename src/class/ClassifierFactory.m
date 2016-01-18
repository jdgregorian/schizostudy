classdef ClassifierFactory
  methods (Static)
    function obj = createClassifier(method, settings)
      switch lower(method)
        case 'svm'
          obj = SVMClass(settings);
        case 'rf'
          obj = RfModel(settings);
        case 'bbob'
          obj = PreciseModel(settings);
        otherwise
          warning(['ClasssifierFactory.createClassifier: ', method, ' -- no such classifier available']);
          obj = [];
      end
    end
  end
end
