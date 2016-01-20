classdef (Abstract) Classifier
  properties (Abstract)
    method     % classifier method
    settings
    classifier % own classifier
    implementation
  end

  methods (Abstract)
    % training function
    obj = trainClassifier(obj, trainingData, trainingLabels)
    
    % prediction of classifier
    y = predict(obj, testingData, trainingData, trainingLabels)
  end

  methods
    
    function obj = train(obj, data, labels)
    % obj = trainCVClassifier(method, trainingData, 
    % trainingLabels, settings) trains cross-validated classifier according to
    % settings.gridsearch.
    %
    % Gridsearch is implemented in a very primitive way. At each level points
    % from the parameter space are layed out using linear/logaritmic scale. At
    % each point is trained classifier with aproprite settings. Point with the
    % best performance is the center point of the next level search.
    %
    % Example: 
    %   Find linear SVM classifier in 3-level gridsearch using properties
    %   'boxconstraint' and 'kktviolationlevel'. 'boxconstraint' bounds are 0.2
    %   and 10, and 'kktviolationlevel' bounds are 0 and 0.99. Gridsearch will
    %   use 5 points for 'boxconstraint' and 4 for 'kktviolationlevel'. Scale
    %   at first level is logaritmic for 'boxconstraint' and at the rest is 
    %   linear. Scale is linear for 'kktviolationlevel' at all levels.
    %
    %   settings.gridsearch.mode = 'simple';
    %   settings.gridsearch.levels = 3;
    %   settings.gridsearch.properties = {'boxconstraint', 'kktviolationlevel'};
    %   settings.gridsearch.bounds = {[0.2, 10], [0, 0.99]};
    %   settings.gridsearch.npoints = [5, 4]; 
    %   settings.gridsearch.scaling = {{'log', 'lin', 'lin'},
    %                                  {'lin', 'lin', 'lin'}};
    % 
    % Warning: 'settings' can be in different format - use prepareSettings
    %          first
    %
    % See also:
    %   trainClassifier, prepareSettings

      % no gridsearch set -> regular training
      if ~isfield(obj.settings, 'gridsearch')
        obj = obj.trainClassifier(data, labels);
        return
      end

      % prepare properties 
      CVProperties = defopts(obj.settings.gridsearch, 'properties', {});
      if isempty(CVProperties)
        warning('No properties in gridsearch set. Running regular training.')
        obj = obj.trainClassifier(data, labels);
        return
      end
      nProperties = length(CVProperties);

      nLevels = defopts(obj.settings.gridsearch, 'levels', ones(nProperties, 1));
      if length(nLevels) < nProperties
      % fill the rest with the last
        nLevels(end+1 : nProperties) = nLevels(end);
      end
      maxLevels = max(nLevels);

      CVGridBounds = defopts(obj.settings.gridsearch, 'bounds', mat2cell([zeros(nProperties, 1), ones(nProperties, 1)], ones(nProperties, 1)));
      CVGridPoints = defopts(obj.settings.gridsearch, 'npoints', ones(nProperties, 1)*11);
      if length(CVGridPoints) < nProperties
        CVGridPoints(end+1 : nProperties) = CVGridPoints(end);
      end
      CVGridPoints(CVGridPoints < 2) = 2;

      % scaling
      defScale = {'lin'};
      defScale = {defScale(ones(maxLevels, 1))};
      CVGridScaling = defopts(obj.settings.gridsearch, 'scaling', defScale);
      if ~iscell(CVGridScaling{1})
        CVGridScaling = {CVGridScaling};
        CVGridScaling = CVGridScaling(ones(1, nProperties));
      end
      for p = 1:nProperties
        if length(CVGridScaling{p}) < maxLevels
          CVGridScaling{p}(end+1 : maxLevels) = CVGridScaling{p}(end);
        end
      end

      nCombinations = prod(CVGridPoints);
      gridClass = cell(nCombinations, 1);

      % CV prepare
      Nsubjects = size(data, 1);
      kFold = defopts(obj.settings.gridsearch, 'kfold', 5);
      if strcmpi(kFold, 'loo') || (kFold > Nsubjects)
        kFold = Nsubjects;
        CVindices = 1:Nsubjects;
      else
        CVindices = crossvalind('kfold', Nsubjects, kFold);
      end

      bestLevelClassifier = cell(maxLevels, 1);
      bestLevelPerformance = zeros(maxLevels, 1);

      lb = NaN(1, nProperties);
      ub = NaN(1, nProperties);

      % level loop
      for l = 1:maxLevels
        % prepare grid values
        gridValues = cell(nProperties, 1);
        for p = 1:nProperties
          if l == 1
            lb(p) = CVGridBounds{p}(1);
            ub(p) = CVGridBounds{p}(2);
          elseif l <= nLevels(p) && ~strcmp(CVProperties{p}, 'hiddenSizes')
            gridValues{p} = obj.gridScaling(lb(p), ub(p), CVGridScaling{p}{l}, CVGridPoints(p) + 2);
            lb(p) = gridValues{p}(2);
            ub(p) = gridValues{p}(end - 1);      
          end
          gridValues{p} = gridScaling(lb(p), ub(p), CVGridScaling{p}{l}, CVGridPoints(p));
        end    

        % prepare settings
        gridSettings = obj.settings;
        for i = 0:nCombinations - 1
          exactParamId = i; 
          % extract appropriate values
          for p = 1:nProperties
            ParamId = mod(exactParamId, CVGridPoints(p));
            % neural network architecture
            if strcmp(CVProperties{p}, 'hiddenSizes')
              gridSettings.(CVProperties{p}) = ones(1, l)*gridValues{p}(ParamId+1);
%               eval(['gridSettings.', settingsStructName(obj.method), '.', CVProperties{p}, ' = [',num2str(ones(1, l)*gridValues{p}(ParamId+1)),'];'])
            else
              gridSettings.(CVProperties{p}) = gridValues{p}(ParamId+1);
%               eval(['gridSettings.', settingsStructName(obj.method), '.', CVProperties{p}, ' = ',num2str(gridValues{p}(ParamId+1)),';'])
            end
            exactParamId = (exactParamId - ParamId) / CVGridPoints(p);
          end
          gridClass{i+1} = ClassifierFactory.createClassifier(obj.method, gridSettings);
        end

        % main training loop
        performance = zeros(nCombinations, 1);
        for s = 1:nCombinations
          fprintf('Gridsearch level %d, settings %d/%d...\n', l, s, nCombinations)
          correctPredictions = false(Nsubjects, 1);
          for f = 1:kFold
            foldIds = f == CVindices;
            % training
            trainingData = data(~foldIds, :);
            trainingLabels = labels(~foldIds);
            try
              gridClass{i+1} = gridClass{i+1}.trainClassifier(trainingData, trainingLabels);
              % testing
              testingData = data(foldIds,:);
              testingLabels = labels(foldIds);
              y = gridClass{i+1}.predict(testingData, trainingData, trainingLabels);
              % output check
              if iscell(y)
                if length(y) == 1
                  y = str2double(y{1});
                else
                  y = str2double(y);
                end
              end
              correctPredictions(foldIds) = y == testingLabels;
            catch err
              fprintf('%s\n', err.message)
              % if error continue
            end
          end
          performance(s) = sum(correctPredictions)/Nsubjects;
        end

        [bestLevelPerformance(l), bestClassifierID] = max(performance); 
        bestLevelClassifier{l} = gridClass{bestClassifierID};

        % calculate new bounds
        lowerID = bestClassifierID - 1; % TODO: non-primitive gridsearch
        for p = 1:nProperties
          ParamId = mod(lowerID, CVGridPoints(p));
          if nLevels(p) > l && ~strcmp(CVProperties{p}, 'hiddenSizes')
            % first settings = lower bound
            if ParamId == 0
              % boundary value
              lb(p) = gridValues{p}(ParamId + 1);
            else
              % non-boundary value
              lb(p) = gridValues{p}(ParamId);
            end
            % last settings = upper bound
            if ParamId + 1 == CVGridPoints(p)
              % boundary value
              ub(p) = gridValues{p}(ParamId + 1);
            else
              % non-boundary value
              ub(p) = gridValues{p}(ParamId + 2);
            end
          else
            lb(p) = gridValues{p}(1);
            ub(p) = gridValues{p}(end);
          end
          lowerID = (lowerID - ParamId) / CVGridPoints(p);
        end

      end

      % train the best classifier settings
      [~, bestClassifierID] = max(bestLevelPerformance); 
      bestClassifier = bestLevelClassifier{bestClassifierID}.trainClassifier(data, labels);
      obj.classifier = bestClassifier.classifier;
      obj.settings = bestClassifier.settings;

    end
  end
  
end

function s = gridScaling(lb, ub, scaling, nPoints)
    % Function returns 'nPoints' using 'scaling' from interval [lb, ub]
    %
    % Input:
    %   lb      - lower bound
    %   ub      - upper bound
    %   scaling - scaling type | 'lin', 'log'
    %   nPoints - number of points to lay out

      if lb > ub
        h = lb;
        lb = ub;
        ub = h;
      end

      if strcmpi(scaling, 'log') 
        % NaN protection
        if lb < 0 && ub < 0
          protlb = abs(lb);
          protub = abs(ub);
        elseif lb <= 0
          protlb = eps;
          protub = ub - lb + eps;
        else
          protlb = lb;
          protub = ub;
        end
        s = logspace(log10(protlb), log10(protub), nPoints);
        % return original scaling
        if lb < 0 && ub < 0
          s = -s;
        elseif lb <= 0
          s = s + lb - eps;
          s(1) = lb;
          s(end) = ub;
        end
      else
        s = linspace(lb, ub, nPoints);
      end

    end