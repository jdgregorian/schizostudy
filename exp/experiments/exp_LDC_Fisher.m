% experiment for similarity testing of lda and Fisher from PRTools

FCdata = fullfile('data','data_FC_190subjects.mat');
filename = 'exp_lda_Fisher';
expfolder = fullfile('exp','experiments');
mkdir(expfolder,filename)

%% linear discriminant classifier (PRTools) - equal priors
clear settings

settings.lda.prior = [0.5;0.5];
settings.lda.note= 'lda (PRTools) with equal priors';
settings.implementation = 'prtools';

[~, ~, ~, classLDA_equal] = classifyFC(FCdata,'lda',settings, fullfile(filename,'lda_equal.mat'));

%% linear discriminant classifier (PRTools) - size-dependent priors
clear settings

settings.lda.prior = [];
settings.lda.note= 'lda (PRTools) with size-dependent priors';
settings.implementation = 'prtools';

[~, ~, ~, classlda_none] = classifyFC(FCdata,'lda',settings, fullfile(filename,'lda_none.mat'));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.note = 'Default Fisher';
settings.implementation = 'prtools';

[~, ~, ~, classFisher] = classifyFC(FCdata,'fisher',settings, fullfile(filename,'fisher.mat'));

%% final results listing

save(fullfile(expfolder,filename,'classes'),'classlda_equal','classlda_none','classFisher')
listSettingsResults(fullfile(expfolder, filename));