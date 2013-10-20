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

    T = align_shape(d3,e);

    %apply transformation to points and get rid of last column.
    d3 = [d3 ones(size(d3,1),1)]*T'; 
    d3 = d3(:,1:2);
    %remove out of bound points
    
    d3 = d3(d3(:,1)<=w & d3(:,1)>=1 & d3(:,2)<=h & d3(:,2)>=1,:); 
    d3 = round(d3);
    cidx = cidx +1; 
end

time = toc;

%compute aligned image
aligned = zeros(h,w);
aligned(sub2ind([h w],d3(:,2),d3(:,1))) = 1;

err = evalAlignment(aligned,im1);

imf = displayAlignment(im1,im2,aligned,false);
figure,imshow(imf);

%compute our transformation by minimizing the least square
%Please correct me if I am wrong but my understanding is that using the
%Pseudo inverse to solve an overconstrained system of equation in matlab
%results in solving the system by minimizing the least square.
%In the case of our two set of corresponding points, we want to find the
%affine matrix mpping the first set of points to the other.
%
%       [a b tx]
%   T = [c d ty]
%       [0 0  1]
%
%In class we had instead [a b c d tx ty] and compute a matrix based to
%determine these parameters.
%Instead of solving the system and returning the coefficient of the matrix
%we just compute the matrix and return it.
%Just like we said in class, I am using an affine transformation matrix instead
%of the regular cos(theta) -sin(theta) decomposition in order to linearly
%solve the system.
%More generally, if T maps [x y] to [u v] we have the formula
%
%
%       [u]   [a b tx] [x]
%       [v] = [c d ty]*[y]
%       [1]   [0 0  1] [1]
% 
%       or [u]  [a b tx] [x]
%          [v] =[c d ty]*[y]
%                        [1]   
%
% If we apply transpose on both side
%                    
%   [u v] = [x y 1]*A
%
%           [a  c ]
%where A =  [b  d ]
%           [tx ty]
%
%   A = [x y 1] \ [u v]
%We rebuild T by appending [0 0 1]  to A
function T = align_shape(xi,xf)

r = size(xi,1);
X = [xi ones(r,1)];
U = xf;

A = X\U;

T = A';
T(3,:) = [0 0 1];

