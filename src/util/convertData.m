function convertData(filename)
% converts input data from .mat file to binary files

    data = load(filename);
    
    % make directories for result binaries
    resultFolder = filename(1:end-4);
    mkdir(resultFolder);
    convertOneClass('volunteers',data.indices_volunteers,data.FC,resultFolder);
    convertOneClass('patients',data.indices_patients,data.FC,resultFolder);
    
    % zip results
    zip([resultFolder,'.zip'],resultFolder);
end

function convertOneClass(className,indices,data,resultFolder)
    mkdir(fullfile(resultFolder,className));
    for d = 1:length(indices)
        resultname = fullfile(resultFolder,className,['FC_',num2str(d)]);
        fid = fopen(resultname,'w');
        fwrite(fid,data(indices(d),:,:),'double');
        fclose(fid);
    end
    
    fprintf('%d %s datafiles successfully converted.\n',length(indices),className);
end