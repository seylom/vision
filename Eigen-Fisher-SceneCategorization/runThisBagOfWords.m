function runThisBagOfWord

clear;
%please set the path to the directory
path = 'C:\Users\seylom\Desktop\UIUC\Courses\CS-543_computer_vision\homework\hw5\hw5_supplemental';

load('sift_desc.mat');
load('gs.mat');
vocabsize = 500;
levels = 1;

%% retrieve all descriptors from images
dframe = [];
dscript = [];

imgnum = size(train_F,2);
imgnumtest = size(test_F,2);

%retrieve a subset of descriptors
numc = size(dscript,2);


numperimage = ceil(10000/imgnum);
uscript = [];

for i =1:imgnum
   %dframe = [dframe train_F{i}];
   %dscript = [dscript train_D{i}];

   des = train_D{i};
    
   r = randperm(size(des,2));
   
   df = des(:,r);
   
   uscript = [uscript df(:,1:numperimage)];
end

kmean_result = fullfile(path,'kmean_result.mat');
%% run k-means on the subset
if (~exist(kmean_result,'file'))
    [clusters,passign] = kmeansClustering(vocabsize,double(uscript'));
    save(kmean_result,'clusters','passign')
else
    load(kmean_result);
end

%0 level pyramid

%trainfeat = zeros(imgnum,vocabsize*levels);
trainfeat = zeros(imgnum,vocabsize);
testfeat = zeros(imgnumtest,vocabsize);

%% quantization of images:
quant_file = fullfile(path,'quant.mat');

tic;
if (~exist(quant_file,'file'))
for i=1:imgnum

    all_desc = double(train_D{i});

    % compute cluster assignment
    X = double(all_desc'); 
    K = size(clusters,1);
    N = size(X,1);
    cNorm = sum(clusters.^2, 2);
    xNorm = sum((X').^2, 1);
    assignMatrix = repmat(cNorm,1, N) + repmat(xNorm, K, 1) - 2*clusters*X';
    [minValue, idx] = min(assignMatrix,[], 1);

    trainfeat(i,:) = histc(idx,1:K);
    trainfeat(i,:) = trainfeat(i,:)/sum(trainfeat(i,:));
    
    
    %trainfeat(i,:) = buildBagOfWordPyramid(h,w,levels,train_F{i}, ..
    %                           train_D{i},clusters,vocabsize);
    %
    
end

for i=1:imgnumtest

    all_desc = double(test_D{i});

    %NOTE: this section below helped speed up the algorithm
    X = double(all_desc'); 
    K = size(clusters,1);
    N = size(X,1);
    cNorm = sum(clusters.^2, 2);
    xNorm = sum((X').^2, 1);
    assignMatrix = repmat(cNorm,1, N) + repmat(xNorm, K, 1) - 2*clusters*X';
    [minValue, IDX] = min(assignMatrix,[], 1);
    %END NOTE.

    testfeat(i,:) = histc(IDX,1:K);
    testfeat(i,:) = testfeat(i, :)/sum(testfeat(i,:));
    
    %testfeat(i,:) = buildBagOfWordPyramid(h,w,levels,test_F{i}, ..
    %                           test_D{i},clusters,vocabsize);
    %
    
end
  
save(quant_file,'trainfeat','testfeat');

else
    load(quant_file);  
end
toc;

%% classify
labels = zeros(imgnumtest,1);

for i=1:imgnumtest
    vect = testfeat(i,:);
    dist = sum(abs(trainfeat - repmat(vect,[imgnum 1])),2);
    
    %dist = sqrt(sum((trainfeat - repmat(vect,[imgnum 1])).^2,2));
    [~,id] = min(dist);
    
    labels(i) = train_gs(id);
end

accuracy = numel(find(labels == test_gs'))/imgnumtest;
    
end

