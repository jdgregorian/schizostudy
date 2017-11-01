% dimension reduction plotting script test

expfolder = fullfile('exp', 'experiments', 'fcpaper');
expname = 'exp_fcpaper_orig';

perf_orig = returnResults(fullfile(expfolder, expname));

expname = 'exp_fcpaper_pca36';
perf_pca36 = returnResults(fullfile(expfolder, expname));

perf_imp = perf_pca36 - perf_orig;

%%

% max_perf = max(max(perf_imp));
% min_perf = min(min(perf_imp));
% max_diff = max(abs(max_perf), abs(min_perf));

% image((perf_imp/max_diff+1)*128, 'CDataMapping', 'scaled');
figure(1)
image(perf_imp, 'CDataMapping', 'scaled');

colorbar
title('Difference in performances of PCA36 and original data')

%%

figure(2)
image(perf_imp, 'CDataMapping', 'scaled');

colorbar
title('Difference of PCA36 and original data limited to [-0.2; 0.2]')
caxis([-0.2 0.2])

%%

figure(3)
image(perf_imp, 'CDataMapping', 'scaled');

colorbar
title('Positive PCA influence on performance')
caxis([0 0.2])
