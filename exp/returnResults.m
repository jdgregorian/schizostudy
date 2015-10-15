function performances = returnResults(folders)
% performances = returnResults('folders') lists results of FC performance testing 
% in 'folders' cellarray to 'performance'. 
%
% See Also:
% listSettingsResults

  if nargin == 0 || isempty(folders)
    help listSettingsResults
    return
  end
  
  Nfolders = length(folders);
  
  for f = 1:Nfolders
    if ~isdir(folders{f})
      warning('Folder %s does not exist! Results cannot be printed!', folders{f})
      return
    end
    
    folderPos = strfind(folders{f}, filesep);
    foldername = folders{f}(folderPos(end) + 1 : end);
    resultname = [folders{f}, filesep, foldername, '.txt'];
    fileList = dir([folders{f}, filesep, '*.mat']);
    nFiles = length(fileList);

    % loading data
    settings = cell(nFiles,1);
    method = cell(nFiles,1);
    data = cell(nFiles,1);
    performance = cell(nFiles,1);
    avgPerformance = zeros(nFiles,1);
    errors = cell(nFiles,1);
    nEmptyFiles = 0;
    usefulFiles = true(nFiles,1);

    fprintf('Loading data...\n')
    neededVariables = {'settings', 'method', 'data', 'performance', 'avgPerformance', 'errors'};
    for fil = 1:nFiles
      variables = load([folders{f} filesep fileList(fil).name], neededVariables{:});
      if all(isfield(variables, neededVariables(1:end-1)))
        settings{fil - nEmptyFiles} = variables.settings;
        method{fil - nEmptyFiles} = variables.method;
        data{fil - nEmptyFiles} = variables.data;
        performance{fil - nEmptyFiles} = variables.performance;
        avgPerformance(fil - nEmptyFiles) = variables.avgPerformance;
        if isfield(variables, 'errors')
          errors{fil-nEmptyFiles} = variables.errors;
        end
      else
        nEmptyFiles = nEmptyFiles + 1;
        usefulFiles(fil) = false;
      end
    end
    
    performances{f} = avgPerformance(usefulFiles);
  end
end