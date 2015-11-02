function createScript(dataname, expname, param)
% Function for creating testing scripts for parameter testing
% 
% createScript() - shows help
% createScript(filename) - creates script from file with structure param
% createScript(dataname, param) - creates experimental script for testing 
%                                 'param' parametres on 'dataname' data
% createScript(dataname, expname, param) - creates 'expname' script

  % initialize
  switch nargin
    case 0
      help createScripts
      return
    case 1
      eval(dataname) % evaluate script with parametres
      if ~exist('param', 'var')
        error('Script %s does not include structure ''param''!', dataname)
      end
      if ~exist('expname', 'var')
        separators = strfind(dataname,filesep);
        expname = ['exp_',dataname(separators(end)+1:end-2)];
      end
    case 2
      param = expname;
      if ~exist('expname', 'var')
        separators = strfind(dataname,filesep);
        expname = ['exp_',dataname(separators(end)+1:end-2)];
      end
  end
  expfolder = fullfile('exp', 'experiments');
  
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
  FID = fopen([expfolder, filesep, expname, '.m'], 'w');
  if FID == -1
    error('Cannot open %s!', resultname)
  end
  
  fprintf(FID,'%% Script for parametres testing in %s experiment.\n', expname);
  fprintf(FID,'%%\n');
  fprintf(FID,'%% Variables ''FCdata'', ''filename'', ''expfolder'' and ''datamark'' should be\n');
  fprintf(FID,'%% defined before run.\n');
  fprintf(FID,'%%\n');
  fprintf(FID,'%% Created on %s\n', datestr(now));
  fprintf(FID,'\n');
  fprintf(FID,'%s\n', char(37*ones(1,75)));
  fprintf(FID,'%%%% initialization\n');
  fprintf(FID,'if ~exist(''FCdata'', ''var'')\n');
  fprintf(FID,'  FCdata = fullfile(''data'', ''data_FC_190subjects.mat'');\n');
  fprintf(FID,'end\n');
  fprintf(FID,'if ~exist(''filename'', ''var'')\n');
  fprintf(FID,'  filename = ''%sSettings'';\n', expname);
  fprintf(FID,'end\n');
  fprintf(FID,'if ~exist(''expfolder'', ''var'')\n');
  fprintf(FID,'  expfolder = fullfile(''exp'', ''experiments'');\n');
  fprintf(FID,'end \n');
  fprintf(FID,'if ~exist(''datamark'', ''var'')\n');
  fprintf(FID,'  datamark = '''';\n');
  fprintf(FID,'else\n');
  fprintf(FID,'  datamark = [''_'', datamark];\n');
  fprintf(FID,'end\n');
  fprintf(FID,'mkdir(expfolder,filename)\n');
  fprintf(FID,'\n');
  fprintf(FID,'%s\n', char(37*ones(1,75)));

  % printing settings cycle
  for m = 1:nMethods
    for p = 0:nCombinations(m) - 1
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
          val = [char(39), param(actualID).values{ParamId+1}, char(39)];
        else
          val = num2str(param(actualID).values{ParamId+1});
        end
        fprintf(FID,'settings.%s = %s;\n', param(actualID).name, val);
        exactParamId = (exactParamId-ParamId)/nParamValues(actualID);        
      end
      fprintf(FID,'\n');
      fprintf(FID,'classifyFC(FCdata, ''%s'', settings, fullfile(filename, [''%s'', datamark, ''.mat'']));\n\n', ...
                  method{m}, [expname, '_', method{m}, '_', num2str(p+1)]);
    end
    fprintf(FID,'%s\n', char(37*ones(1,75)));
  end
  
  % printing finalization
  fprintf(FID,'%%%% final results listing\n');
  fprintf(FID,'\n');
  fprintf(FID,'listSettingsResults(fullfile(expfolder, filename));\n');

  fclose(FID);

end
