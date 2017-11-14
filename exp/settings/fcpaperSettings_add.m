% Script for additional testing settings of classifiers used in FC paper 
% (2017)
%
% Variables 'FCdata', 'filename', 'expfolder' and 'datamark' should be 
% defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data', 'data_FC_180subjects.mat');
end
if ~exist('filename', 'var')
  filename = 'fcpaperSettings';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp', 'experiments');
end 
if ~exist('datamark', 'var')
  datamark = '';
else
  datamark = ['_', datamark];
end
mkdir(expfolder, filename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SVM
% linear - iter 15000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 15000);
settings.note = 'Linear SVM. Maximum iterations 15000 (default).';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter15', datamark, '.mat']));

%% linear - iter 20000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 20000);
settings.note = 'Linear SVM. Maximum iterations 20000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter20', datamark, '.mat']));

%% linear - iter 25000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 25000);
settings.note = 'Linear SVM. Maximum iterations 25000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter25', datamark, '.mat']));

%% linear - iter 30000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 30000);
settings.note = 'Linear SVM. Maximum iterations 30000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter30', datamark, '.mat']));

%% linear - iter 50000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 50000);
settings.note = 'Linear SVM. Maximum iterations 50000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter50', datamark, '.mat']));

%% linear - iter 100000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.options = statset('MaxIter', 100000);
settings.note = 'Linear SVM. Maximum iterations 100000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_iter100', datamark, '.mat']));

%% linear - autoscale 'off', iter 15000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 15000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 15000 (default).';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter15', datamark, '.mat']));

%% linear - autoscale 'off', iter 20000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 20000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 20000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter20', datamark, '.mat']));

%% linear - autoscale 'off', iter 25000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 25000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 25000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter25', datamark, '.mat']));

%% linear - autoscale 'off', iter 30000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 30000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 30000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter30', datamark, '.mat']));

%% linear - autoscale 'off', iter 50000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 50000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 50000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter50', datamark, '.mat']));

%% linear - autoscale 'off', iter 100000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 100000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 100000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter100', datamark, '.mat']));

%% linear - autoscale 'off', iter 200000
clear settings

settings.svm.kernel_function = 'linear';
settings.svm.autoscale = false;
settings.svm.options = statset('MaxIter', 200000);
settings.note = 'Linear SVM. Autoscale ''off''. Maximum iterations 200000.';

classifyFC(FCdata, 'svm', settings, fullfile(filename, ['svm_linear_noauto_iter200', datamark, '.mat']));

%% final results listing

listSettingsResults(fullfile(expfolder, filename));