%   meanshift_gauss(im,hr,hs) is the meanshift segmentation procedure I
%   im1 : an RGB image
%   hr: the badnwidth in the color domain
%   hs: the bandwidth in the position domain
%   tol: the tolerance used
%   clusterSize: minimum size of a cluster

function  meanshift_gauss(im1,hr,hs,tolerane,clusterSize)

im0 = im1;
im1 = rgb2luv(im1);


[imh imw ~] = size(im1);

hrsq = hr^2;
hssq = hs^2;

r = reshape(im1 (:,:,1)',1,[])';
g = reshape(im1 (:,:,2)',1,[])';
b = reshape(im1 (:,:,3)',1,[])';
[x y] = ind2sub(im1,1:numel(r));

oldPts = [r g b x' y']; %last column
pts = oldPts;

rcount = numel(r);

% added columns to track 
% - whether the point has been assigned a cluster
% - the cluster index
% - the count of points in the cluster.

ptcluster = [oldPts zeros(rcount,3)] ;

clusterCount = 0;
clusters = zeros(1,7);

tic;
for i=1:rcount
   
    tol = 100;
    
    while (tol > tolerane)  % shift until convergence.
        current = pts(i,:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %compute closest neighbors to be used
        
        inDist = closestPointsDistIdx(oldPts,4*hssq,current);
        inColorAndDist = closestPointsColorIdx(inDist,4*hrsq,current);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %compute weights:
        
        ptm = current(ones(1,size(inColorAndDist,1)),:);
        
        sqdiff = (inColorAndDist - ptm).^2;

        dr = sum(sqdiff(:,1:3),2);
        ds = sum(sqdiff(:,4:5),2);
        
        w = exp(-dr./hrsq).*exp(-ds./hssq); 
        
        pts(i,:) = w'*inColorAndDist/sum(w); 
        tol = abs(pts(i,:) - current);
            
    end
   
    % consolidate modes
    mergeIdx = 0;
    
    if (clusterCount > 0)
        inCDist = closestPointsDistIdx(clusters,hssq,current);
        inCDistCColor = closestPointsColorIdx(inCDist,hrsq,current);
        [~, mx] = max(inCDistCColor(:,6),[],1); 
        mergeIdx = inCDistCColor(mx,7);
    end
    
    if (mergeIdx > 0)
        %merge cluster and save the average color in the cluster
        clusters(mergeIdx,1:3) = 0.5*(pts(i,1:3) + clusters(mergeIdx,1:3));
        ptcluster(i,7) = mergeIdx;
        ptcluster(i,8) = ptcluster(i,8) + 1;   
        density = numel(find(ptcluster(:,7)== mergeIdx));
        clusters(mergeIdx,6) = density;
        ptcluster(i,1:3) = clusters(mergeIdx,1:3);
    else
        clusterCount = clusterCount +1;
        clusters(clusterCount,1:5) = pts(i,:);
        ptcluster(i,7) = clusterCount;
        ptcluster(i,8) = 1;
        clusters(clusterCount,6) = 1;
        clusters(clusterCount,7) = clusterCount;
        ptcluster(i,1:3) = clusters(clusterCount,1:3);
    end
      
    ptcluster(i,6) = 1;
     
end
toc;

%merge clusters with fewer than a certain number of points
realcount = 0;
ccount = size(clusters,1);

for i=1:ccount;
    clust = clusters(i,:);
    if (clust(6) < clusterSize)
        %find largest nearest cluster
        inClDist = closestPointsDistIdx(clusters,hssq,clust);
        inClDistCColor = closestPointsColorIdx(inClDist,3*hrsq,clust);
        
        inClDistCColor = inClDistCColor(inClDistCColor(:,6)>clusterSize,:);

        if (size(inClDistCColor,1)>0)
            dsort = sortrows(inClDistCColor,-6);
            clust(1:3) = dsort(1,1:3);
            matches = ptcluster(:,7) == i;
            
            repClust = clust(ones(1,rcount),:);
            
            ptcluster(matches,1:3) = repClust(matches,1:3);
        else
            realcount = realcount+1;
        end
    else
        realcount  = realcount +1;
    end
end
disp(['number of clusters:' num2str(realcount)]);

im2r = reshape(pts(:,1)',[imw imh]);
im2g = reshape(pts(:,2)',[imw imh]);
im2b = reshape(pts(:,3)',[imw imh]);

im2 = zeros(imh,imw,3);
im2(:,:,1) = im2r';
im2(:,:,2) = im2g';
im2(:,:,3) = im2b';

im3r = reshape(ptcluster(:,1)',[imw imh]);
im3g = reshape(ptcluster(:,2)',[imw imh]);
im3b = reshape(ptcluster(:,3)',[imw imh]);

im3 = zeros(imh,imw,3);
im3(:,:,1) = im3r';
im3(:,:,2) = im3g';
im3(:,:,3) = im3b';

im2 = luv2rgb(im2);
im3 = luv2rgb(im3);

figure,imshow(im2);
figure,imshow(im3);

end

function pointsIdx = closestPointsDistIdx(inputPoints,radius,centerPoint)
    dist =  (centerPoint(4) - inputPoints(:,4)).^2   +   (centerPoint(5) - inputPoints(:,5)).^2;
    pointsIdx = inputPoints(dist<radius,:);
end

function pointsIdx = closestPointsColorIdx(inputPoints,radius,centerPoint)
    dist = (centerPoint(1) - inputPoints(:,1)).^2   + ...
        (centerPoint(2) - inputPoints(:,2)).^2 + (centerPoint(3) - inputPoints(:,3)).^2;
    pointsIdx = inputPoints(dist<radius,:);
end
