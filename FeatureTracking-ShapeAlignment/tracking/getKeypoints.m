function [keyXs,keyYs] = getKeypoints(im,tau)

im_or = im;

[w h] = size(im);
%convert the image from 0-255 to 0-1 scale
im = im2double(im);
gfil = fspecial('gaussian',7,1);

% we optionally blur the image first
im = imfilter(im,gfil);

% compute the derivatives the image
im_x = imfilter(im,[1 0 -1]);
im_y = imfilter(im,[1 0 -1]');

%compute the squares
im_x2 = im_x.*im_x;
im_y2 = im_y.*im_y;
im_xy = im_x.*im_y;

%apply another gaussian filter
gfil2 = fspecial('gaussian',7,1);
im_gx2 = imfilter(im_x2,gfil2);
im_gy2 = imfilter(im_y2,gfil2);
im_gxy = imfilter(im_xy,gfil2);

%subplot(1,3,1),imagesc(im_gx2);
%subplot(1,3,2),imagesc(im_gy2);
%subplot(1,3,3),imagesc(mat2gray(im_gxy));

im3 = zeros(w,h);

det = im_gx2.*im_gy2 - im_gxy.*im_gxy;
tra = im_gx2 + im_gy2;
traf = 0.06*(tra).^2;
hr = det - traf;
im3 =  hr;

%I couldn't find a way to improve this
% for i=1:w
%     for j= 1:h
%         M = [im_gx2(i,j) im_gxy(i,j);im_gxy(i,j) im_gy2(i,j)];
%         im3(i,j) = det(M) - 0.06*(trace(M))^2;
%     end
% end

%set all points with value lower than tau to 0
im3(im3<tau) = 0;

%use 5x5 window to select points and replace non maximum points with the
%max of the neighbour. Then set to zero the center elements that were smaller than
%their neighbours.

imtp = ordfilt2(im3,25,ones(5,5));
im3(im3<imtp) = 0;


[keyYs keyXs] = find(im3);

