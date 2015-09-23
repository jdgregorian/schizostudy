function createScripts(dataname, expname, param)
% Function for creating testing scripts for parameter testing
% 
% createScripts() - shows help
% createScripts(filename) - creates script from file with structure param
% createScripts(data,param) - creates script testing parameters in param
%                             on data

  if nargin < 2
    if nargin < 1
      help createScripts
      return
    end
    expname = dataname;
    eval(expname) % evaluate script with parametres
  end
  
  methodParamID = find(strcmpi({param.name},'method'), 1);
  
  % no method set
  if isempty(methodParamID)
    fprintf('In parametres structure is missing field ''method''!\n')
    return
  end
  
  % extract methods from param
  method = param(methodParamID).values;
  param(methodParamID) = [];
  
  % marks positions of appropriate settings
  nParams = length(param);
  nParamValues = zeros(1,nParams);
  nMethods = length(method);
  mySettings = zeros(nMethods,nParams);

  for p = 1:nParams
    nParamValues(p) = length(param(p).values);
  end
  
  for m = 1:nMethods
    myCellSet = strfind({param.name}, [method{m},'.']);
    for p = 1:nParams
      if myCellSet{p} == 1
        mySettings(m,p) = nParamValues(p);
      end
    end
  end
  
  % count number of parameters combinations
  nonMethodParams = sum(mySettings) == 0;
  mySettings(:,nonMethodParams) = repmat(nParamValues(nonMethodParams),nMethods,1);
  nCombinations = prod(mySettings + ~mySettings,2);

  % printing initialization
  FID = fopen([expname,'.m'],'w');
  
  fprintf(FID,'%% Script for parametres testing in %s experiment.\n', expname);
  fprintf(FID,'\n');
  fprintf(FID,'%%%% initialization\n');
  fprintf(FID,'FCdata = ''%s'';\n', dataname);
  fprintf(FID,'filename = ''%s'';\n', expname);
  fprintf(FID,'expfolder = fullfile(''exp'', ''experiments'');\n');
  fprintf(FID,'mkdir(expfolder, filename);\n');
  fprintf(FID,'\n');
  fprintf(FID,'%s\n', char(37*ones(1,75)));

  % printing settings cycle
  for m = 1:nMethods
    fprintf(FID,'%% %s\n', method{m});
    fprintf(FID,'\n');
    for p = 0:nCombinations{m} - 1
      fprintf(FID,'%%%% %s\n', method{m});
      fprintf(FID,'clear settings\n');
      fprintf(FID,'\n');
      parIDs = find(mySettings(m,:));
      exactParamId = p; 
      % TODO: finish printing algorithm
      for j = 1:length(parIDs)
        actualID = parIDs(j);
        ParamId = mod(exactParamId,nParamValues(actualID));
        if ischar(param(actualID).values{ParamId+1})
          fprintf(FID,['settings(i+1).',param(actualID).name,' = ''',param(actualID).values{ParamId+1},''';']);
        else
          fprintf(FID,['settings(i+1).',param(actualID).name,' = ',num2str(param(actualID).values{ParamId+1}),';']);
        end
        exactParamId = (exactParamId-ParamId)/nParamValues(actualID);        
      end
      fprintf(FID,'perf = classifyFC(FCdata,''%s'',settings, fullfile(filename,''%s''));', ...
                  method{m}, [expname, '_', method{m}, '_', num2str(p), '.mat']);
    end
    fprintf(FID,'\n%s\n',char(37*ones(1,75)));
  end
  
  % printing finalization
  fprintf(FID,'%%%% final results listing\n');
  fprintf(FID,'\n');
  fprintf(FID,'listSettingsResults(fullfile(''results'', filename));\n');

  fclose(FID);

end
