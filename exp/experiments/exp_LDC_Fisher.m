% experiment for similarity testing of LDC and Fisher from PRTools

FCdata = fullfile('data','data_FC_190subjects.mat');
filename = 'exp_LDC_Fisher';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% linear discriminant classifier (PRTools) - equal priors
clear settings

settings.ldc.prior = [0.5;0.5];
settings.ldc.note= 'LDC (PRTools) with equal priors';

[perf, ~, ~, classLDC_equal] = classifyFC(FCdata,'ldc',settings, fullfile(filename,'ldc_equal.mat'));

%% linear discriminant classifier (PRTools) - size-dependent priors
clear settings

settings.ldc.prior = [];
settings.ldc.note= 'LDC (PRTools) with size-dependent priors';

[perf, ~, ~, classLDC_none] = classifyFC(FCdata,'ldc',settings, fullfile(filename,'ldc_none.mat'));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.note = 'Default Fisher';

[perf, ~, ~, classFisher] = classifyFC(FCdata,'fisher',settings, fullfile(filename,'fisher.mat'));

%% final results listing

save(fullfile(expfolder,filename,'classes'),'classLDC_equal','classLDC_none','classFisher')
listSettingsResults(fullfile(expfolder, filename));