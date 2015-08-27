function reduceData(data, subjectOut, regionOut)
% Reduce connectivity matrix and indices vectors and save dataset.

  % check input
  if nargin < 3
    regionOut = [71,72];
    if nargin < 2
      subjectOut = [66,101,102,104,113,144,152,166,178,179,189,190,192];
      if nargin < 1
        help reduceData
        return
      end
    end
  end

  load(data)
  
  % find out type of connectivity matrix
  if exist('FC','var')
    newName = 'FC';
    CM = FC;
  elseif exist('SC','var')
    newName = 'SC';
    CM = SC;
  else
    error('FC or SC matrix has to be included in file!')
  end

  % decide which subjects and regions stay
  nOrigSub = size(CM,1);
  subjectStay = true(1,nOrigSub);
  subjectStay(subjectOut) = false;
  regionStay = true(1,size(CM,2));
  regionStay(regionOut) = false;

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
