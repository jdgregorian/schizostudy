fid = fopen('test.txt','w');
fwrite(fid,'%d',ans);
fclose(fid)
clear fid

%startupSchizo
%classifyFC('data/data_FC_203subjects.mat','RF')

fprintf('Imma here!!!\n')

quit
