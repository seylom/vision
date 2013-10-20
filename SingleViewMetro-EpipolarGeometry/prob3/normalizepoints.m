function [T x] = normalizepoints(x)

b = x;
%compute image centroids
c = mean(x(:,1:2));

%shift all points

x(:,1) = x(:,1) -c(1);
x(:,2) = x(:,2) -c(2);

m = mean(sqrt(x(:,1).^2 + x(:,2).^2));
v = sqrt(2)/m;

T = [v 0 -v*c(1);0 v -v*c(2);0 0 1];

x = T*[b ones(size(b,1),1)]';
