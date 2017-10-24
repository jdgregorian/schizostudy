% dimension reduction plotting script test

expfolder = fullfile('exp', 'experiments');
expname = 'exp_fcpaper_orig';

perf_orig = returnResults(fullfile(expfolder, expname));

expname = 'exp_fcpaper_pca36';
perf_pca36 = returnResults(fullfile(expfolder, expname));

%%

perf_imp = perf_pca36 - perf_orig;

max_perf = max(max(perf_imp));
min_perf = min(min(perf_imp));
max_diff = max(abs(max_perf), abs(min_perf));

% image((perf_imp/max_diff+1)*128, 'CDataMapping', 'scaled');
image(perf_imp, 'CDataMapping', 'scaled');

colorbar