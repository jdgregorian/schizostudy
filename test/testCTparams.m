function testCTparams(data,param,filename)
% function for testing parametres of MATLAB classification tree
% 
% testRFparams(filename) - continues with computations in filename
% testRFparams(data)     - starts new computations with default parametres
% testRFparams(data,param) - starts new computations with specified 
%                            parametres
% testRFparams(data,param,filename) - starts new computations with 
%                                     specified parametres and saves them
%                                     in filename

  if nargin < 1
    data = fullfile('data','data_FC_190subjects.mat');
  end

  load(data)
  if exist('performance','var') && exist('settings','var') && ...
      exist('elapsedTime','var') && exist('FC','var')
    filename = data;
    newMode = false;
  else
    newMode = true;
  end

  % start new experiment
  if newMode
    if nargin < 3
      filename = [fullfile('results','testCTparams'),num2str(randi(10^6)),'.mat'];
    end

    if nargin < 2 || strcmp(param,'default')
      clear param
      param(1).name = 'MaxCat';
      param(1).values = {0,1,5,10,20,50};% {100,400,1000};
      param(end+1).name = 'MergeLeaves';
      param(end).values = {'on','off'}; % {0.5,0.8,1};
      % param(end+1).name = 'SampleWithReplacement';
      % param(end).values = {'on','off'}; % {'on','off'};
      % param(end+1).name = 'NVarToSample';
      % param(end).values = {10,50,100,500,2000,'all'}; % {100,500,1000,2000,'all'};
      param(end+1).name = 'MinLeaf';
      param(end).values = {1,3,5,8}; % {1,3,8};

      % fitctree params
      % param(end+1).name = 'CrossVal';
      % param(end).values = {'on','off'}; % {'on','off'};
      % param(end+1).name = 'Prune';
      % param(end).values = {'on','off'}; % {'on','off'};
      param(end+1).name = 'SplitCriterion';
      param(end).values = {'gdi','twoing','deviance'}; % {'gdi','twoing','deviance'};
      param(end+1).name = 'Surrogate';
      param(end).values = {'off','on','all'}; % {'off','on','all'};
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
    
    % gain category indices
    indicesPatients = indices_patients;
    categoryValues = zeros(1,size(FC,1));
    categoryValues(indicesPatients) = 1;
    
    for i = 0:nCombinations - 1
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
    perf = classifyFC(data,'mtltree',settings(setId));
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

function S = sLoad(filename)
% function for secure loading of file
  notSaved = true;
  while notSaved
    try
      S = load(filename);
      notSaved = false;
    catch
      fprintf('Waiting for access to file %s ...',filename)
    end
  end
end
