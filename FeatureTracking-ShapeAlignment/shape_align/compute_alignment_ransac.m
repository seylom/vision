function [time err] = compute_alignment(im1,im2)

im1 = im2double(im1);
im2 = im2double(im2);

[h w] = size(im1);

%retrieve non-zero points
[y1 x1] = find(im1 > 0);
[y2 x2] = find(im2 > 0);

%compute the centroid of both images and align them.
c1 = [sum(x1)/numel(x1);sum(y1)/numel(y1)];
c2 = [sum(x2)/numel(x2);sum(y2)/numel(y2)];

%c1 = [round(sum(x1)/numel(x1));round(sum(y1)/numel(y1))];
%c2 = [round(sum(x2)/numel(x2));round(sum(y2)/numel(y2))];

t = c1 - c2; % compute translation to initialize alignment
x3 = x2 + t(1);
y3 = y2 + t(2);

x3 = round(x3);
y3 = round(y3);

%use ICP to compute nearest neighbours to estimate the transformation.
%use bwdist to compute nearest neighbours.

im_result = zeros(h,w);
d3 = [x3 y3];

%get rid of pixels that are off boundaries.
d3 = d3(d3(:,1)<=w & d3(:,1)>=1 & d3(:,2)<=h & d3(:,2)>=1,:);

for k=1:numel(d3(:,1))
    p = d3(k,:);
    im_result(p(2),p(1)) = 1;
end

[Dr Lr] = bwdist(im1);

e = zeros(size(d3));

cidx = 0;

tic;

err = 9999;

% I decided to spend some time to vectorize some of the loops
% I was initially doing to set matrix elements. The result seems acceptable

while (cidx <50)
    
    id = sub2ind([h w],d3(:,2),d3(:,1));
    idx = Lr(id);
    
    [k l] = ind2sub(size(im_result),idx);
    e = [l k];

    T = align_shape_ransac(d3,e);

    %apply transformation to points and get rid of last column.
    d3 = [d3 ones(size(d3,1),1)]*T'; 
    d3 = d3(:,1:2);
    %remove out of bound points
    
    d3 = d3(d3(:,1)<=w & d3(:,1)>=1 & d3(:,2)<=h & d3(:,2)>=1,:); 
    d3 = round(d3);
    cidx = cidx +1; 
    
    aligned = zeros(h,w);
    aligned(sub2ind([h w],d3(:,2),d3(:,1))) = 1;
    err = evalAlignment(aligned,im1);   
    if (err <0.8)
      break;
    end
     
end

time = toc;

%compute aligned image
aligned = zeros(h,w);
aligned(sub2ind([h w],d3(:,2),d3(:,1))) = 1;

err = evalAlignment(aligned,im1);

imf = displayAlignment(im1,im2,aligned,false);
figure,imshow(imf);

%This is a try at using ransac to determine the affine matrix parameters
%we only need three correspondance to determine those parameters so we
%sample just this three point matches and perform the calculation.
%Tweaking professor Hoiem ransac_fit function to
%work for affine transformation we have
% u = a*x +b*y +tx
% v = c*x +d*y +ty
%
% =>     [x1 y1 0   0  1 0]
%        [0  0  x1 y1  0 1]
%    A = [x2 y2 0   0  1 0]
%        [0  0  x2 y2  0 1]
%        ...
% unknowns : a,b,c,tx,ty
function T = align_shape_ransac(x, y)
%best values
%obtained for N =3 and thresh = 8
N = 3;
thresh = 8;



bestcount = 0;
inliers = zeros(size(x));

for k = 1:N
    rp = randperm(size(x,1));
    tx = x(rp,:);
    ty = y(rp,:);
    
    a1 =  tx(1:6,:);
    b1 =  ty(1:6,:);

    %T = align_shape(a1,b1);
    
    T = [a1 ones(6,1)]\b1;
    T = T';
    T(3,:) = [0 0 1];
    
    V = [x ones(size(x,1),1)]*T';
    
    nin = sum(abs(y(:,2)-V(:,2))<thresh);
    if nin > bestcount
        bestcount = nin;
        inliers = abs(y(:,2) - V(:,2)) < thresh;
    end
end

xa = [x inliers];
ya = [y inliers];

c = xa(xa(:,3) == 1,1:2);
d = ya(ya(:,3) == 1,1:2);

r = size(d,1);

T =  [c ones(r,1)]\d;
T = T';
T(3,:) = [0 0 1];

