function [mag theta] = orientedFilterMagnitude(im)

%create our filter bank with 6 different angles:
sigma = 2;
N = 6;
x_filters = cell(1,N);
y_filters = cell(1,N);

%create a low pass filter
g = fspecial('gaussian',6*sigma+1,sigma);

%we will created oriented filters using the gaussian derivatives
dGx = imfilter(g,[1 0 -1]);
dGy = imfilter(g,[1 0 -1]');

%compute our oriented filters.
for i=1:N
    a = pi*(i-1)/N;
    x_filters{i} = cos(a)*dGx;
    y_filters{i} = sin(a)*dGy;

    %subplot(1,N,i),imshow(mat2gray(x_filters{i} + y_filters{i}));
end

%process the image
img = im2double(im);
[h w c] = size(im);

mag = zeros(h,w,c);
theta = zeros(h,w,c);

mag_all = zeros(h,w,c,N);
theta_all = zeros(h,w,c,N);

%compute for each filter
for i=1:3
    for k=1:N
        %compute the filtered result along x and y
        img_fil_x = imfilter(img(:,:,i),x_filters{i});
        img_fil_y = imfilter(img(:,:,i),y_filters{i});

        %compute the magnitude and theta along the channels (R,G or B)
        img_fil_mag = sqrt(img_fil_x.*img_fil_x + img_fil_y.*img_fil_y);
        img_fil_theta = atan2(-img_fil_y,img_fil_x);

        mag_all(:,:,i,k) = img_fil_mag;
        theta_all(:,:,i,k) = img_fil_theta;
    end
      
    theta(:,:,i) = img_fil_theta;
end

[mag id]=  max(mag_all,[],4);

img_mag = sqrt(mag(:,:,1).*mag(:,:,1) + mag(:,:,2).*mag(:,:,2) + mag(:,:,3).*mag(:,:,3));

%compute orientation from channel with largest gradient.
[m_max idx] = max(mag,[],3);

theta_mag = zeros(h,w);

%store orientation of channel with highest gradient magnitude.
for i=1:h
    for j=1:w
        theta_mag(i,j) = theta(i,j,idx(i,j));
    end
end

%subplot(1,3,1),imshow(im);
%subplot(1,3,2),imshow(img_mag);
%subplot(1,3,3),imshow(theta_mag);

