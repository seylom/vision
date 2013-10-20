function [newXs newYs actives] = predictTranslationAll(startXs,startYs,im0,im1)

sz = numel(startXs);

actives = zeros(sz,1);
newXs = zeros(sz,1);
newYs = zeros(sz,1);

im0 = im2double(im0);
im1 = im2double(im1);

%compute first image gradients along x and y.
Ix = imfilter(im0,[1 0 -1]);
Iy = imfilter(im0,[1 0 -1]');

%compute the new coorditinates for the point
%and indicates if it is still active or lost.
for i=1:numel(startXs)
    
    [x y b] = predictTranslation(startXs(i),startYs(i),Ix,Iy,im0,im1);
    
    newXs(i) = x;
    newYs(i) = y; 
    actives(i) = b;
   
end