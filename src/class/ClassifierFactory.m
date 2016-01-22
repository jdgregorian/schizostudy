classdef ClassifierFactory
  methods (Static)
    function obj = createClassifier(method, settings)
      
      % PRTools classifiers
      if strcmp(settings.implementation, {'prtools', 'prt'})
        switch lower(method)
          case 'lda'
            obj = LDAClassPRT(settings);
        end
        
      % Matlab classifiers
      else
        switch lower(method)
          case 'knn'
            obj = KNNClassMTL(settings);
          case 'lda'
            obj = LDAClassMTL(settings);
          case 'llc'
            obj = LLCClassMTL(settings);
          case 'mrf'
            obj = MRFClassMTL(settings);
          case 'nb'
            obj = NBClassMTL(settings);
          case 'qda'
            obj = QDAClassMTL(settings);
          case 'rda'
            obj = RDAClassMTL(settings);
          case 'svm'
            obj = SVMClassMTL(settings);
          otherwise
            warning(['ClasssifierFactory.createClassifier: ', method, ' -- no such classifier available']);
            obj = [];
        end
      end
      
    end
  end
end
