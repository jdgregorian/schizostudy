function createScripts(dataname, param, numOfMachines)
% Function for creating testing scripts for parameter testing
% 
% createScripts() - shows help
% createScripts(filename) - creates script from file with structure param
% createScripts(data,param) - creates script testing parameters in param
%                             on data
% createScripts(data,param,numOfMachines) - creates numOfMachines scripts

  if nargin < 3
    if nargin < 2
      if nargin <1
        help createScripts
        return
      end
      filename = dataname;
      eval(filename) % evaluate script with parametres
    end
    numOfMachines = 1;
  end
  
% prepare variables to save file
  nParams = length(param);
  for i = 1:nParams
      nParamValues(i) = length(param(i).values);
  end
  nCombinations = prod(nParamValues);

  performance = NaN(nCombinations,1);
  elapsedTime = NaN(nCombinations,1);
  available = true(nCombinations,1);

  for i = 0:nCombinations - 1 % printing cycle
    exactParamId = i; 
    % extract appropriate values
    for j = 1:nParams
        ParamId = mod(exactParamId,nParamValues(j));
        if ischar(param(j).values{ParamId+1})
          eval(['settings(i+1).',param(j).name,' = ''',param(j).values{ParamId+1},''';'])
        else
          eval(['settings(i+1).',param(j).name,' = ',num2str(param(j).values{ParamId+1}),';'])
        end
        exactParamId = (exactParamId-ParamId)/nParamValues(j);
    end
  end

  % save created settings and variables
  save(filename,'performance','settings','elapsedTime','FC','categoryValues');
  fprintf('Settings saved to %s\n',filename)

  % start new experiment
  if newMode
    if nargin < 3
      filename = [fullfile('results','testCTparams'),num2str(randi(10^6)),'.mat'];
    end

    if nargin < 2 || strcmp(param,'default')
      clear param
      param(1).name = 'tree.MaxCat';
      param(1).values = {0,1,5,10,20,50};% {100,400,1000};
      param(end+1).name = 'tree.MergeLeaves';
      param(end).values = {'on','off'}; % {0.5,0.8,1};
      % param(end+1).name = 'tree.SampleWithReplacement';
      % param(end).values = {'on','off'}; % {'on','off'};
      % param(end+1).name = 'tree.NVarToSample';
      % param(end).values = {10,50,100,500,2000,'all'}; % {100,500,1000,2000,'all'};
      param(end+1).name = 'tree.MinLeaf';
      param(end).values = {1,3,5,8}; % {1,3,8};

      % fitctree params
      % param(end+1).name = 'tree.CrossVal';
      % param(end).values = {'on','off'}; % {'on','off'};
      % param(end+1).name = 'tree.Prune';
      % param(end).values = {'on','off'}; % {'on','off'};
      param(end+1).name = 'tree.SplitCriterion';
      param(end).values = {'gdi','twoing','deviance'}; % {'gdi','twoing','deviance'};
      param(end+1).name = 'tree.Surrogate';
      param(end).values = {'off','on','all'}; % {'off','on','all'};
    end

  end
  
  % perform calculations
  while any(available)
    
    load(filename)
    
    setId = find(available,1,'first');
    available(setId) = false;
    % mark setId settings as not available
    save(filename,'available','-append')
    
    disp(settings(setId))
    tic
    perf = classifyFC(dataname,'mtltree',settings(setId));
    elapsed = toc;
    
    % load again for actual data
    load(filename)
    performance(setId) = perf;
    elapsedTime(setId) = elapsed;
    save(filename,'performance','elapsedTime','-append');
    fprintf('Results for settings number %d saved.\n',setId)
  end
  
  if ~(any(available) && any(isnan(performance)))
    fprintf('Experiment completed.\n')
  else
    fprintf('Available computations completed.\nCheck other machines if they still compute.\n')
  end
end
