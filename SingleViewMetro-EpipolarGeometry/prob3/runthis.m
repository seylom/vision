im1 = imread('chapel00.png');
im2 = imread('chapel01.png');

%compute fundamental matrix using the 8-point algorithm 
d = load('prob3.mat');
size(d.matches);

%select the first 8 matches.
pts = d.matches(1:8,:);
%A = zeros(8,9);

A1 = zeros(8,2);
A2 = zeros(8,2);

%plotmatches(im1,im2,[d.c1 d.r1]',[d.c2 d.r2]',d.matches');
% 
% a1 = [d.c1(d.matches(:,1)) d.r1(d.matches(:,1))];
% b1 = [d.c2(d.matches(:,2)) d.r2(d.matches(:,2))];
% 
% g = [a1 b1];

%a3 = zeros(size(a1,1),4);
a3 = zeros(8,4);

%good matches selected : [x1 y1 x2 y2]
a3(1,:) = [145 48 174 56];
a3(2,:) = [144 13 172 20];
a3(3,:) = [146 65 174 73];
a3(4,:) = [174 181 209 192];
a3(5,:) = [179 131 215 140];
a3(6,:) = [331 145 362 155];
a3(7,:) = [271 166 309 175];
a3(8,:) = [265 203 303 213];

x1 = a3(:,1:2);
x2 = a3(:,3:4);

a1 = x1;
a2 = x2;

%plotmatches(im1,im2,x1',x2',[1 1;2 2;3 3;4 4; ...
                            % 5 5;6 6;7 7;8 8]');

% %compute image centroids
% c1 = mean(x1(:,1:2));
% c2 = mean(x2(:,1:2));
% 
% %shift all points
% 
% x1(:,1) = x1(:,1) -c1(1);
% x1(:,2) = x1(:,2) -c1(2);
% 
% x2(:,1) = x2(:,1) -c2(1);
% x2(:,2) = x2(:,2) -c2(2);
% 
% m_1 = mean(sqrt(x1(:,1).^2 + x1(:,2).^2));
% m_2 = mean(sqrt(x2(:,1).^2 + x2(:,2).^2));
% 
% v1 = sqrt(2)/m_1;
% v2 = sqrt(2)/m_2;
% 
% x1 = x1*v1;
% x2 = x2*v2;

%[T1 x1] = normalizepoints(x1);
%[T2 x2] = normalizepoints(x2);

x1 = T1*[a1 ones(size(a1,1),1)]'; 
x2 = T2*[a2 ones(size(a2,1),1)]';

x1 = x1';
x2 =  x2';

A = [x2(:,1).*x1(:,1) x2(:,1).*x1(:,2) x2(:,1) x2(:,2).*x1(:,1) x2(:,2).*x1(:,2) x2(:,2) x1(:,1) x1(:,2) ones(size(x1,1),1) ];

%using singular value decomposition to solve A
[U, S, V] = svd(A);
f = V(:, end); 
F1 = reshape(f, [3 3])';

%enforcing the det(F) = 0 constraint.
[U, S, V] = svd(F1); 
S(3,3) = 0; 
F1 = U*S*V';

F = T2'*F1*T1;

F(:,1) = F(:,1) /sqrt(sum(F(:,1).^2));
F(:,2) = F(:,2) /sqrt(sum(F(:,2).^2));
F(:,3) = F(:,3) /sqrt(sum(F(:,3).^2));

[m n] = size(im2);
epi_x = 1:1:n;
%compute epipolar lines for first point:

figure(2),imshow(im2);

for i=1:8
    e1 = F*[a1(i,:) 1]';
    
    %e1 = e1./sqrt(e1(1,1)^2 + e1(2,1)^2);
    %ax +by + c = 0 ==> y = (-c-ax)/b
    epi_y = (-e1(3,1) - e(1,1)*epi_x)/e1(2,1);

    hold on;
    plot(epi_x,epi_y,'w');
end




