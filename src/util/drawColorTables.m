load('data/errortable.txt')
load('data/ngenetable.txt')

figure(1)
hold on
subplot(2,1,1)
grid off
pcolor(ngenetable)
colorbar
title('ngenetable','FontSize',16)
subplot(2,1,2)
pcolor(errortable)
colorbar
grid off
title('errortable','FontSize',16)
hold off

clear errortable ngenetable