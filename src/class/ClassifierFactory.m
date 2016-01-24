classdef ClassifierFactory
  methods (Static)
    function obj = createClassifier(method, settings)
      
      % PRTools classifiers
      if any(strcmp(settings.implementation, {'prtools', 'prt'}))
        switch lower(method)
          % artificial neural network
          case 'ann'
            obj = ANNClassPRT(settings);
          % Fisher's linear discriminant classifier
          case 'fisher'
            obj = FisherClassPRT(settings);
          % linear discriminant analysis
          case 'lda'
            obj = LDAClassPRT(settings);
          % logistic linear classifier
          case 'llc'
            obj = LLCClassPRT(settings);
          % Naive Bayes classifier
          case 'nb'
            obj = NBClassPRT(settings);
          % quadratic discriminant analysis
          case 'qda'
            obj = QDAClassPRT(settings);
          % random forest
          case 'rf'
            obj = RFClassPRT(settings);
          % decision tree
          case 'tree'
            obj = TreeClassPRT(settings);
        end
        
      % Matlab classifiers
      else
        switch lower(method)
          % artificial neural network
          case 'ann'
            obj = ANNClassMTL(settings);
          % k-nearest neighbours
          case 'knn'
            obj = KNNClassMTL(settings);
          % linear discriminant analysis
          case 'lda'
            obj = LDAClassMTL(settings);
          % logistic linear classifier
          case 'llc'
            obj = LLCClassMTL(settings);
          % Naive Bayes
          case 'nb'
            obj = NBClassMTL(settings);
          % linear perceptron
          case 'perc'
            obj = PercClassMTL(settings);
          % quadratic discriminant analysis
          case 'qda'
            obj = QDAClassMTL(settings);
          % radial basis function network
          case 'rbf'
            obj = RBFClassMTL(settings);
          % regularized linear discriminant analysis
          case 'rda'
            obj = RDAClassMTL(settings);
          % random forest
          case 'rf'
            obj = RFClassMTL(settings);
          % support vector machine
          case 'svm'
            obj = SVMClassMTL(settings);
          % decision tree
          case 'tree'
            obj = TreeClassMTL(settings);
          otherwise
            warning(['ClasssifierFactory.createClassifier: ', method, ' -- no such classifier available']);
            obj = [];
        end
      end
      
    end
  end
end
