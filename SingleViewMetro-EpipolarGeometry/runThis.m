function runThis

%load all 51 images
imgs = cell(51,1);
for i=1:51
    imgs{i} = imread(strcat(strcat('Images/hotel.seq',int2str(i-1)),'.png'));
end

%extract the feature keypoints to be tracked using the 
%Harris criteria
[startXs startYs] = getKeypoints(imgs{1},0.0000003);

figure(1),imshow(imgs{1});
hold on;
plot(startXs,startYs,'g.','linewidth',3);
hold off;

pause(.1);

[h w] = size(imgs{1});

%remove points that can't accomodate a 15x15 window
wid = 7;
active = (startXs > wid) & (startYs > wid) & (startXs < w -wid) & (startYs < h -wid);

% %randomly select 20 points
% index = randperm(numel(startXs),20);
% startXs = startXs(index);
% startYs = startYs(index);

count = numel(startXs);
pointXs = zeros(count,51);  % 51 images
pointYs = zeros(count,51);

pointXs(:,1) = startXs;
pointYs(:,1) = startYs;

disp('preforming tracking ...');

activePoints = zeros(1,count);

for j =1:50
   im1 = imgs{j};
   im2 = imgs{j+1};

   [Xs Ys active] = predictTranslationAll(pointXs(:,j),pointYs(:,j),active,im1,im2);
   
   pointXs(:,j+1) = Xs;
   pointYs(:,j+1) = Ys; 
   
   activePoints = active;
end

%%
%plot points path.
%randomly select 20 points to display.
figure(2),imshow(imgs{1});
hold on;
index = randperm(count,20);

for i = 1:51
    scatter(pointXs(index,i),pointYs(index,i),'g.');
end

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Finding lost keypoints!');

figure(3),imshow(imgs{1});
hold on;

%check the last frame for lost points
lostIdx = find(activePoints == 0);

plot(startXs(lostIdx),startYs(lostIdx),'r.');

hold off;

disp('Tracking completed!');

end

