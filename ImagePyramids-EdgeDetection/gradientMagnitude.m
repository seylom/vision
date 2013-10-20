function [mag theta] = gradientMagnitude(im,sigma)


im = im2double(im);
[h w c] = size(im);

mag = zeros(h,w,c);
theta = zeros(h,w,c);

hs = 3*sigma;

%creating the gaussian filter
gfil = fspecial('gaussian',2*hs+1,sigma);

%creating our gradient filters
dGx = imfilter(gfil,[1 0 -1]);
dGy = dGx';

for i=1:3
    %apply the gaussian to the image
    img_blur = imfilter(im(:,:,i),gfil);
    
    %compute gradients along x and y
    img_fil_x = imfilter(img_blur,dGx);
    img_fil_y = imfilter(img_blur,dGy);
    
    %compute the magnitude and theta along the channels (R,G or B)
    img_fil_mag = sqrt(img_fil_x.*img_fil_x + img_fil_y.*img_fil_y);
    img_fil_theta = atan2(-img_fil_y,img_fil_x);
    
    mag(:,:,i) = img_fil_mag;
    theta(:,:,i) = img_fil_theta;
end

img_mag = sqrt(mag(:,:,1).*mag(:,:,1) + mag(:,:,2).*mag(:,:,2) + mag(:,:,3).*mag(:,:,3));

%compute orientation from channel with largest gradient.
[m_max idx] = max(mag,[],3);

theta_mag = zeros(h,w);

%storing orientation of channel with highest gradient magnitude.
for i=1:h
    for j=1:w
        theta_mag(i,j) = theta(i,j,idx(i,j));
    end
end

subplot(1,2,1),imshow(img_mag);
subplot(1,2,2),imshow(theta_mag);