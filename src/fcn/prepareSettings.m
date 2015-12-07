function [settings, cellset] = prepareSettings(method, settings)
% Prepares settings for classifiers. Use before trainClassifier.
%
% See also:
%   trainClassifier

  cellset = [];
  
  % prior settings
  if ~isfield(settings, 'prior')
    settings.prior = [0.5, 0.5];
  end

  % implementation settings
  settings.implementation = defopts(settings, 'implementation', 'matlab');
  % Fisher and decision tree are implemented only in PRTools
  if any(strcmpi(method, {'fisher', 'dectree'}))
    settings.implementation = 'prtools';
  end

  % PRTools implementations
  if any(strcmpi(settings.implementation, {'prtools', 'prt'}))
    prwaitbar off
    switch method
      case 'dectree' % decision tree (treec)
        settings.tree = defopts(settings, 'tree', []);
        settings.tree.crit = defopts(settings.tree, 'crit', 'infcrit');
        settings.tree.prune = defopts(settings.tree, 'prune', 0);
        if settings.tree.prune < -1
          warning('This implementation does not support pruning level lower than -1. Switching to 0.')
          settings.tree.prune = 0;
        end
        
      case 'rf' % random forest (randomforestc or adaboostc)
        settings.forest = defopts(settings, 'forest', []);
        settings.forest.nTrees = defopts(settings.forest, 'nTrees', 11);
        settings.forest.N = defopts(settings.forest, 'N', 1);
        settings.forest.learning = defopts(settings.forest, 'learning', 'bagging');
        settings.forest.rule = defopts(settings.forest, 'rule', 'wvotec');
        
      case {'lda', 'qda'} % linear or quadratic discriminant classifier
        settings.da = defopts(settings, method, []);
        settings.da.R = defopts(settings.da, 'R', 0);
        settings.da.S = defopts(settings.da, 'S', 0);
        
      case 'fisher' % Fisher's linear discriminant (fisherc)
        if isfield(settings,'fisher')
          warning('Fisher''s linear discriminant (PRTools) do not accept additional settings.')
        end
        
      case 'nb' % naive Bayes
        if isfield(settings,'nb')
          warning('Naive Bayes (PRTools) do not accept additional settings.')
        end
        
      case 'llc' % logistic linear classifier (loglc)
        if isfield(settings,'llc')
          warning('Logistic linear classifier (PRTools) do not accept additional settings.')
        end
        
      otherwise
        settings = [];
         
    end
  else %if any(strcmpi(settings.implementation, {'matlab', 'mtl'}))
    switch method
      case 'svm' % support vector machine
        settings.svm = defopts(settings, 'svm', []);
        cellset = cellSettings(settings.svm);

      case {'rf', 'mrf'} % forests
        settings.forest = defopts(settings, 'forest', []);
        % gain number of trees 
        settings.forest.nTrees = defopts(settings.forest, 'nTrees', 11);

        if strcmpi(method, 'mrf')
            cellset = cellSettings(settings.forest, {'nTrees'});
        end

      case {'lintree', 'mtltree', 'svmtree'} % trees
        settings.tree = defopts(settings, 'tree', []);

        if strcmpi(method, 'mtltree')
          cellset = cellSettings(settings.tree);
        end

      case 'nb' % naive Bayes
        settings.nb = defopts(settings, 'nb', []);
        settings.nb.prior = defopts(settings, 'prior', 'uniform');
        cellset = cellSettings(settings.nb);

      case 'knn' % k-nearest neighbours
        settings.knn = defopts(settings, 'knn', []);
        settings.knn.k = defopts(settings.knn, 'k', 1);
        settings.knn.distance = defopts(settings.knn, 'distance', 'euclidean');
        settings.knn.rule = defopts(settings.knn, 'rule', 'nearest');

      case 'llc' % logistic linear classifier
        if isfield(settings,'llc')
          warning('Logistic linear classifier do not accept additional settings.')
        end

      case 'lda' % linear discriminant analysis
        settings.lda = defopts(settings, 'lda', []);
        settings.lda.type = defopts(settings.lda, 'type', 'linear');
        if all(~strcmpi(settings.lda.type, {'linear', 'diaglinear'}))
          warning('Not possible matlab LDA settings. Switching to LDA type ''linear''...\n')
          settings.lda.type = 'linear';
        end
        
      case 'qda' % quadratic discriminant analysis
        settings.qda = defopts(settings, 'qda', []);
        settings.qda.type = defopts(settings.qda, 'type', 'quadratic');
        if all(~strcmpi(settings.qda.type, {'quadratic', 'diagquadratic'}))
          warning('Not possible matlab QDA settings. Switching to LDA type ''quadratic''...\n')
          settings.qda.type = 'quadratic';
        end
        
      case 'rda' % regularized discriminant analysis (RDA 14)
        settings.rda = defopts(settings, 'rda', []);
        settings.rda.alpha = defopts(settings.rda, 'alpha', 0.999999);
        
      case 'perc' % linear perceptron
        if isfield(settings,'perc')
          warning('Linear perceptron do not accept additional settings.')
        end

      case 'ann' % artificial neural network
        settings.ann = defopts(settings, 'ann', []);
        settings.ann.hiddenSizes = defopts(settings.ann, 'hiddenSizes', []);
        settings.ann.trainFcn = defopts(settings.ann, 'trainFcn', 'trainscg');
        
      case 'rbf' % radial basis function network
        settings.rbf = defopts(settings, 'rbf', []);
        settings.rbf.spread = defopts(settings.rbf, 'spread', 0.1);
        
    end
  end

end