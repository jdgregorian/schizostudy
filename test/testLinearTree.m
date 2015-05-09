% test Linear Tree in 2D
close all

% data
nZeros = 10;
nOnes = 10;
dim = 2;

A = randn(nZeros,dim);
B = randn(nZeros,dim) + 1;
labels = [ones(1,nZeros),zeros(1,nOnes)];

% tree training
L = LinearTree([A;B],labels);

% plot results
figure(1)
scatter(A(:,1),A(:,2))
hold on
scatter(B(:,1),B(:,2),'s')
scatter(L.splitZero(1),L.splitZero(2),'x')
scatter(L.splitOne(1),L.splitOne(2),'x')

x(1) = min([A(:,1);B(:,1)]);
x(2) = max([A(:,1);B(:,1)]);
ybound(1) = ((L.splitZero(1)-x(1))^2-(L.splitOne(1)-x(1))^2+L.splitZero(2)^2-L.splitOne(2)^2)/(2*(L.splitZero(2)-L.splitOne(2)));
ybound(2) = ((L.splitZero(1)-x(2))^2-(L.splitOne(1)-x(2))^2+L.splitZero(2)^2-L.splitOne(2)^2)/(2*(L.splitZero(2)-L.splitOne(2)));
plot(x,ybound,'r')
hold off