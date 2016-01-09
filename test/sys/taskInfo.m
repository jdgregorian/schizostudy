% Startup tasks informations
fprintf('Find PRTools alternatives to already implemented methods.\n')
fprintf('Documentation\n')
fprintf('RDA speed up\n')
fprintf('Labels in column or independent?\n')
fprintf('Generating TeX files with results - adjust returnResults?\n')
fprintf('Split MATLAB and PRTools settings?\n')

fprintf('\nMost recent: \n')
if ~isdir(fullfile('vendor', 'conn'))
  fprintf('\n---------------------------------------------------------------------------------\n\n')
  fprintf('    Download CONN at https://www.nitrc.org/projects/conn to vendor directory\n')
  fprintf('\n---------------------------------------------------------------------------------\n\n')
end
fprintf('    Metacentrum: Findout the error\n')
fprintf('    Improve multilevel gridsearch. Use regoptc in PRTools?\n')
fprintf('    Rewrite experiment to new format\n')
fprintf('    Adjust classifier settings according to matlab version\n')
fprintf('    Is Fisher similar to LDC?\n')
fprintf('    ANN - good settings - Filip Dechterenko?\n')
fprintf('    RBF - good settings - Filip Dechterenko?\n')
fprintf('    Adjust arbabshiraniSettings according to article settings more precisely (cv)\n')
fprintf('    Boosting strategies\n')
fprintf('    Adjust returnResults to multiple output and comparison between different settings\n')
fprintf('    RDA making functional\n')
