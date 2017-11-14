function printHelpFiles(filename)
% printHelpFiles(filename) prints all necessary help files in current
% directory and subdirectories to in TeX file 'filename'.

  if nargin < 1
    texFolder = fullfile('doc', 'tex');
    filename = fullfile(texFolder, 'function_help.tex');
    if ~isdir(texFolder)
      mkdir(texFolder)
    end
  end

  % find files in 'exp' folder
  expNames = searchFile('exp', '*.m');
  % experiments identifiers
  experimentFilesID = strcmp([filesep, 'experiments', filesep], expNames);
  % add files from 'src' folder to 'exp' files without 'experiment' folder
  allNames = [expNames(~experimentFilesID); searchFile('src', '*.m')];
  
  % open file
  FID = fopen(filename, 'w');
  
  % print all helps
  for f = 1:length(allNames)
    [~, funcName] = fileparts(allNames{f});
    fprintf(FID, '\\functionhelp{%s}', funcName);
    fprintf(FID, '{%s}\n\n', help(funcName));
  end

  % close file
  fclose(FID);

end
