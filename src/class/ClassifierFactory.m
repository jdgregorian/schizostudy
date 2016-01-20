classdef ClassifierFactory
  methods (Static)
    function obj = createClassifier(method, settings)
      switch lower(method)
        case 'svm'
          obj = SVMClass(settings);
        case 'knn'
          obj = KNNClass(settings);
        case 'mrf'
          obj = MRFClass(settings);
        otherwise
          warning(['ClasssifierFactory.createClassifier: ', method, ' -- no such classifier available']);
          obj = [];
      end
    end
  end
end
