function reduceSubjects(datafile, subjectOut)
% Exclude subjects in 'subjectOut' and save dataset.
% 
% Input:
%   datafile   - name of datafile with connectivity matrix | string
%   subjectOut - subjects to remove from matrix | double vector
%
% See Also:
% reduceFCData csvexport

  % check input
  if nargin < 2
    help reduceData
    return
  end

  loadedData = load(datafile);
  
  [data, labels] = vectOrMat(loadedData);
  
  assert(~isempty(data), 'Data in %s does not exist!', datafile)
  assert(~isempty(labels), 'Labels in %s does not exist!', datafile)
  
  % which subjects to keep
  if islogical(subjectOut)
    sKeep = ~subjectOut;
  else
    sKeep = true(length(subjectOut), 1);
    sKeep(subjectOut) = false;
  end
  
  data = data(sKeep, :);
  labels = labels(sKeep);
  
  %TODO: only patients are excluded - what to do with healthy?
  %      saving dataset
  
  % create new dataset
  CM = CM(subjectStay, regionStay, regionStay);
  indices_volunteers = 1:(length(indices_volunteers)-sum(ismember(subjectOut,indices_volunteers)));
  indices_patients = length(indices_volunteers) + (1 : (length(indices_patients)-sum(ismember(subjectOut,indices_patients))));
  nNewSub = size(CM,1);
  if nNewSub ~= length([indices_volunteers,indices_patients])
    fprintf('Wrong data extraction! Check original data and extraction vectors!');
  else
    % ask and save new data
    filename = ['data/data_',newName,'_',num2str(nNewSub),'subjects.mat'];
    if exist(filename,'file')
        answer = questdlg(['Overwrite ',filename,' ?'],'Overwritting mat file','Overwrite','No','Overwrite');
        if strcmp('Overwrite',answer)
            overwrite = 1;
        else
            overwrite = 0;
        end
    else
      overwrite = 1;
    end
    if overwrite
      eval([newName,' = CM;'])
      save(filename,newName,'indices_patients','indices_volunteers')
    end
  end
end
