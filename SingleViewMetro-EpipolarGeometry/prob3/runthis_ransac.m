im1 = imread('chapel00.png');
im2 = imread('chapel01.png');

%compute fundamental matrix using the 8-point algorithm 
d = load('prob3.mat');
size(d.matches);

pts = d.matches(:,:);

x1 = [d.c1(pts(:,1)) d.r1(pts(:,1))] ;
x2 = [d.c2(pts(:,2)) d.r2(pts(:,2))] ;

%h1 = 1:size(x1,1);
%plotmatches(im1,im2,x1',x2',[h1' h1']');

F = computeransac(x1,x2);

%compute epipolar lines for first point:
%l1 = F*x1(:,1);

%e1 = [a2(1,:) 1]*F*[a1(1,:) 1]';
%e2 = [a2(2,:) 1]*F*[a1(2,:) 1]';
%e3 = [a2(3,:) 1]*F*[a1(3,:) 1]';
