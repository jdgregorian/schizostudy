%%% SVM

%% linear
clear settings

settings.svm.kernel_function = 'linear';
perf = classifyFC(FCdata,'svm',settings);

%% rbf
clear settings

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 6; % found through gridsearch
perf = classifyFC(FCdata,'svm',settings);

%% rbf

settings.svm.kernel_function = 'rbf';
settings.svm.rbf_sigma = 6; % found through gridsearch
nValues = 10;
for i=1:nValues
  sigma(i) = 10^(i-5);
  settings.svm.rbf_sigma = sigma(i);
  perf(i) = classifyFC(FCdata,'svm',settings);
end
for i = 1:nValues
  fprintf('Sigma:%f   Perf:%f\n',sigma(i),perf(i))
end