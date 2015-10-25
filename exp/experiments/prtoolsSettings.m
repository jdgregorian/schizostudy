% Script containing main settings of PRTools classifiers
%
% Needs variables 'FCdata', 'filename', 'expfolder' and 'datamark' defined before run.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization
if ~exist('FCdata', 'var')
  FCdata = fullfile('data','data_FC_190subjects.mat');
end
if ~exist('filename', 'var')
  filename = 'prtoolsSettings';
end
if ~exist('expfolder', 'var')
  expfolder = fullfile('exp','experiments');
end 
if ~exist('datamark', 'var')
  datamark = '';
else
  datamark = ['_prtools_', datamark];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRTools classification tree - information gain criterion
clear settings

settings.implementation = 'prtools';
settings.tree.crit = 'infcrit';
settings.note = 'Default settings of PRTools decision tree using information gain criterion.';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_inf',datamark,'.mat']));

%% PRTools classification tree - Fisher criterion
clear settings

settings.implementation = 'prtools';
settings.note = 'PRTools decision tree using Fisher criterion.';
settings.tree.crit = 'fishcrit';

classifyFC(FCdata, 'dectree', settings, fullfile(filename, ['dectree_fish',datamark,'.mat']));

%% PRTools classification forest - bagging
clear settings

settings.implementation = 'prtools';
settings.forest.learning = 'bagging';
settings.note = 'Default settings of PRTools bagged random forest.';

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_bagging',datamark,'.mat']));

%% PRTools classification forest - boosting
clear settings

settings.implementation = 'prtools';
settings.forest.learning = 'boosting';
settings.note = 'Default settings of PRTools boosted random forest.';

classifyFC(FCdata, 'rf', settings, fullfile(filename, ['rf_boosting',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.lda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools LDA.';

classifyFC(FCdata,'lda',settings, fullfile(filename, ['lda',datamark,'.mat']));

%% QDA (PRTools)
clear settings

settings.implementation = 'prtools';
settings.qda.prior = [0.5,0.5];
settings.note = 'Default settings of PRTools QDA.';

classifyFC(FCdata,'qda',settings, fullfile(filename, ['qda',datamark,'.mat']));

%% Fisher's linear discriminant (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Fisher''s linear discriminant (PRTools) has no settings.';

classifyFC(FCdata,'fisher',settings, fullfile(filename, ['fisher',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% logistic linear classifier (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default logistic linear classifier settings in PRTools.';

classifyFC(FCdata,'llc',settings, fullfile(filename,['llc',datamark,'.mat']));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% naive Bayes (PRTools)
clear settings

settings.implementation = 'prtools';
settings.note = 'Default PRTools naive Bayes settings.';

classifyFC(FCdata, 'nb', settings, fullfile(filename,['nb',datamark,'.mat']));
