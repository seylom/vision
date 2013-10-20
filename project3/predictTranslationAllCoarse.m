function [newXs newYs] = predictTranslationAllCoarse(startXs,startYs,im0,im1,upNewX,upNewY)

[h w] = size(im0);

winSize = 7;
    
% im0 = im2double(im0);
% im1 = im2double(im1);

%compute first image gradients along x and y.
%Ix = imfilter(im0,[1 0 -1]);
%Iy = imfilter(im0,[1 0 -1]');

[Ix Iy] = gradient(im0);

numpoints = size(startXs,1);

newXs = zeros(size(startXs,1),1);
newYs = zeros(size(startXs,1),1);

%compute the new coorditinates for the point
%and indicates if it is still active or lost.
for i=1:numpoints
    
    active1 = (floor(startXs(i))-winSize)>0 & (floor(startYs(i))-winSize)>0 & (ceil(startXs(i))+winSize)<=w & (ceil(startYs(i))+winSize)<=h;
    if ~active1
      startXs(i)=NaN; 
      startYs(i)=NaN;
      continue;
    end
     
    if ((isnan(upNewX(i)) || (isnan(upNewY(i)))))
      startXs(i)=NaN; 
      startYs(i)=NaN;
      continue;
    end
    
    try
        [newXs(i) newYs(i) ~] = predictTranslationCoarse(startXs(i),startYs(i),Ix,Iy,im0,im1,upNewX(i),upNewY(i));
    catch err
       if (strcmp(err.identifier,'MATLAB:catenate:dimensionMismatch'))

       else
          rethrow(err);
       end
    end   
  

end

