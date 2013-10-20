function opticaflow

imBase = imread('Images/hotel.seq0.png');
%extract the feature keypoints to be tracked using the 
%Harris criteria
[startXs startYs] = getKeypoints(imBase,0.0000003);

figure(1),imshow(imBase);
hold on;
plot(startXs,startYs,'g.','linewidth',3);
hold off;

pause(.1);

disp('preforming tracking ...');

startXs = double(startXs);
startYs = double(startYs);




numpoints = size(startXs,1);

% optical flow.
tic;
for i = 0:50
    im0 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i)),'.png')));
    im1 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i+1)),'.png')));
   
    
    [gx gy] = gradient(im0);
     gt = im1 - im0;
    
    newXs = startXs;
    newYs = startYs;
    
    for k=1:numpoints   
        [newXs newYs] = computeflow(startXs(k), startYs(k), im0, im1, newXs, newYs);    
    end
       
    figure,imshow(im1/255); hold on;
    plot(newXs, newYs, 'g.', 'linewidth',3);title(['image ', num2str(i + 10)]);
end
toc;


end


function computeflow(x,y,img1,img2)
    
end

