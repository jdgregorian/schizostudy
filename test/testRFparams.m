clear

param(1).name = 'nTrees';
param(1).values = {100};% {100,400,1000};
param(end+1).name = 'FBoot';
param(end).values = {0.5,0.8,1}; % {0.5,0.8,1};
param(end+1).name = 'SampleWithReplacement';
param(end).values = {'on','off'}; % {'on','off'};
param(end+1).name = 'NVarToSample';
param(end).values = {10,50,100,500,2000,'all'}; % {100,500,1000,2000,'all'};
param(end+1).name = 'MinLeaf';
param(end).values = {1,3,8}; % {1,3,8};

% fitctree params
% param(end+1).name = 'CrossVal';
% param(end).values = {'on','off'}; % {'on','off'};
% param(end+1).name = 'Prune';
% param(end).values = {'on','off'}; % {'on','off'};
param(end+1).name = 'SplitCriterion';
param(end).values = {'gdi','twoing','deviance'}; % {'gdi','twoing','deviance'};
param(end+1).name = 'Surrogate';
param(end).values = {'off','on','all'}; % {'off','on','all'}; 

filename = [fullfile('results','testRFparams'),num2str(randi(10^6))];
data = fullfile('data','data_FC_203subjects.mat');

nParams = length(param);
for i = 1:nParams
    nParamValues(i) = length(param(i).values);
end
nCombinations = prod(nParamValues);

performance = NaN(nCombinations,1);
elapsedTime = NaN(nCombinations,1);
for i = 0:nCombinations - 1
    exactParamId = i; 
    
    for j = 1:nParams
        ParamId = mod(exactParamId,nParamValues(j));
        if ischar(param(j).values{ParamId+1})
          eval(['settings(i+1).',param(j).name,' = ''',param(j).values{ParamId+1},''';'])
        else
          eval(['settings(i+1).',param(j).name,' = ',num2str(param(j).values{ParamId+1}),';'])
        end
        exactParamId = (exactParamId-ParamId)/nParamValues(j);
    end
    disp(settings)
    
    tic
    [performance(i+1), FC, categoryValues] = classifyFC(data,'rf',settings(i+1));
    elapsedTime(i+1) = toc;
    
    save([filename,'.mat'],'performance','settings','elapsedTime','FC','categoryValues');
end

clear
