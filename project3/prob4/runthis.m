
%%% Load tracks
%After receiving the result from HW2 from Ruiqui, it seems like
%some of my point tracking estimation might have been a bit off.
%When I use my point to compute later the cholesky decomposition I obtain
%an error. I will have to invstigate that a little more

% load('active.mat');
% 
% im_count = 50;
% active_count = 463;
% D = zeros(2*(50), active_count);
% 
% for i = 1:im_count
%     D((i-1)*2+1, :) = activepts{i}(:,1)';
%     D((i)*2, :) = activepts{i}(:,2)';
% end


load('tracked_points.mat');
[im_count, active_count] = size(Xs);
D = zeros(2*im_count, active_count);

for i = 1:im_count
    D((i-1)*2+1, :) = Xs(i,:);
    D((i)*2, :) = Ys(i,:);
end

c =  sum(D, 2)/active_count;
%shift coordinates using centroid
D = D - repmat(c, 1, active_count);

[U S V] = svd(D);
U3 = U(:,1:3);
S3 = sqrt(S(1:3,1:3));
V3 = V(:,1:3);

A = U3*S3;    %motion
X = S3*V3';   %shape

U = zeros(3*im_count, 9);
v = zeros(3*im_count, 1);

for i = 1:im_count
    a1 = A((i-1)*2+1,:);
    a2 = A((i)*2,:);
    
    U((i-1)*3+1,:) = [a1(1).^2, a1(1)*a1(2), a1(1)*a1(3), a1(2)*a1(1), a1(2)^2, a1(2)*a1(3), a1(3)*a1(1), a1(3)*a1(2), a1(3)^2];
    
    U((i-1)*3+2,:) = [a2(1).^2, a2(1)*a2(2), a2(1)*a2(3), a2(2)*a2(1), a2(2)^2, a2(2)*a2(3), a2(3)*a2(1), a2(3)*a2(2), a2(3)^2];
    
    U((i)*3,:) = [a1(1)*a2(1), a2(1)*a1(2), a2(1)*a1(3), a2(2)*a1(1), a2(2)*a1(2), a2(2)*a1(3), a2(3)*a1(1), a2(3)*a1(2), a2(3)*a1(3)];
    
    v((i-1)*3+1) = 1;
    v((i-1)*3+2) = 1; 
    v((i)*3) = 0;
end

L = U\v;
L = reshape(L, 3,3);

%Cholesky decomposition to recover C
C = chol(L,'lower');

%Updating motion and shape matrices.
A = A*C;
X = C\X;

% Display
figure(1)
plot3(X(1,:)', X(2,:)', X(3,:)', 'r.');
grid on;

cam = zeros(im_count, 3);

for i = 1: im_count
   ifr = A((i-1)*2 + 1,:);
   jfr = A((i)*2,:);
   kfr = cross(ifr,jfr);
   cam(i, :) = kfr/norm(kfr);
end

figure(2)
subplot(1,3,1),plot(cam(:,1));
subplot(1,3,2),plot(cam(:,2));
subplot(1,3,3),plot(cam(:,3));

figure(3);
plot3(cam(:,1)', cam(:,2)', cam(:,3)', 'r.');
%grid on;

