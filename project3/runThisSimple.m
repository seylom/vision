function runThisSimple

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

starX2s = startXs;
starY2s = startYs;

% simple tracking.

display('Original tracking -----------------');
tic;
for i = 0:10:40
    display(['Image ', num2str(i + 10)]);
    im0 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i)),'.png')));
    im1 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i+10)),'.png')));
   
    newXs = startXs;
    newYs = startYs;
    
    [newXs newYs] = predictTranslationAllCoarse(startXs, startYs, im0, im1, newXs, newYs);
       
    figure,imshow(im1/255); hold on;
    plot(newXs, newYs, 'g.', 'linewidth',3);title(['image ', num2str(i + 10)]);
end
toc;

display('Coarse to fine tracking -----------------');
% coarse to fine pyramid.
tic;
for i = 0:10:40
    
    display(['Image ', num2str(i + 10)]);
    im0 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i)),'.png')));
    im1 = double(imread(strcat(strcat('Images/hotel.seq',int2str(i+10)),'.png')));

    % Build gaussian pyramid
    scale  = 1.25;
    levels = 5;
    
    imGauss0 = Pyramid(im0, scale, levels);
    imGauss1 = Pyramid(im1, scale, levels);
    
    starX2s = starX2s/(scale.^(levels-1));
    starY2s = starY2s/(scale.^(levels-1));
     
    newXs = starX2s;
    newYs = starY2s;
    
    for j = 1: levels

       im0 =  imGauss0{j}.img;
       im1 =  imGauss1{j}.img;
       [newXs newYs] = predictTranslationAllCoarse(starX2s, starY2s, im0, im1, newXs, newYs);
       
       if(j~=levels)
        newXs = newXs*scale;
        newYs = newYs*scale;
        starX2s = starX2s*scale;
        starY2s = starY2s*scale;
       end
    end
    starX2s = newXs;
    starY2s = newYs;
    
    figure,imshow(im1/255); hold on;
    plot(newXs, newYs, 'g.', 'linewidth',3); 
    title(['Frame ', num2str(i + 10),'/50']);
end
toc;

function  imgGauss = Pyramid(inputImg, scale, numlevel)
    gfil = fspecial('gaussian');
    imgGauss = cell(numlevel,1);
    imgGauss{numlevel}.img = inputImg;
    img = inputImg;
    for k = 2:numlevel
        imSmooth = imfilter(img, gfil, 'replicate');
        img = imresize(imSmooth, 1/scale);
        imgGauss{numlevel-k+1}.img = img;
    end
end

end

