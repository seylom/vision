function categorize(levels,bins)
%  -levels: the number of levels
%  -bins the number of bins per channel with the form [a b c]

rebuild = 0;

%% prepare paths
basepath = 'C:\Users\seylom\Desktop\UIUC\Courses\CS-543_computer_vision\homework\hw5\hw5_supplemental\categorization\';
trainpath = fullfile(basepath,'train');
testpath = fullfile(basepath,'test');

%levels = 1;
%bins = [16 5 20];
%bins = [10 5 10];

%bincomb = prod(bins);
bincomb = sum(bins);

trainhist = fullfile(basepath,['trainhist_',num2str(levels),'.mat']);
testhist = fullfile(basepath,['testhist_',num2str(levels),'.mat']);

%load labels
gs = load('gs.mat');


%% compute histogram for training and testing samples
tic;
if (~exist(trainhist,'file') || rebuild)
    train = dir(fullfile(trainpath, '*.jpg'));
    numtrain = numel(train);
    %numtrain = 500;
    trainh = zeros(numtrain,bincomb*levels);
    
    idx = 1;
    for i=1:numtrain
        im = imread(fullfile(trainpath,[num2str(idx),'.jpg']));
        im = rgb2hsv(im);
        %cform = makecform('srgb2lab');
        %im = applycform(im,cform);
   
        ih = buildPyramid(im,levels,bins); 
        dd = [];
        
        for k = 1:levels
           dd = [dd (ih{k}{1})];  
        end
               
        trainh(idx,:) = dd;
        idx = idx +1;
    end
    
    data.trainh = trainh;
    save(trainhist,'trainh');
else
    th = load(trainhist);
    data.trainh = th.trainh;
end


%compute histogram for testing samples
if(~exist(testhist,'file') || rebuild)
    test = dir(fullfile(testpath, '*.jpg'));
    %numtest = numel(test);
    numtest = 50;
    testh = zeros(numtest,bincomb*levels);
    
    idx = 1;
    for i = 1:numtest
        
        im = imread(fullfile(testpath,[num2str(idx),'.jpg']));
        im = rgb2hsv(im);
        %cform = makecform('srgb2lab');
        %im = applycform(im,cform);
        
        ih = buildPyramid(im,levels,bins);
        
        %ih = simpleColorHist(im,bins);
        
        dd = [];
        
        for k = 1:levels
           dd = [dd (ih{k}{1})];  
        end
               
        testh(idx,:) = dd;
        idx = idx +1;
    end
      
    data.testh = testh;
    save(testhist,'testh');
else
    dh = load(testhist);
    data.testh = dh.testh;
end
toc;
   
%% classify images
tcount = size(data.testh,1);
trcount = size(data.trainh,1);

predlabels = zeros(tcount,1);

for i=1:tcount  
    
    % histogram intersection
    dist =  sum(min(data.trainh,repmat(data.testh(i,:),[trcount 1])),2);  
    [~,id] = min(1-dist);
    
%     dist = data.trainh - repmat(data.testh(i,:),[trcount 1]);
%     dist = sum(abs(dist.^2),2);
    
%     dist = data.trainh - repmat(data.testh(i,:),[trcount 1]);
%     dist = sum(abs(dist),2);

   %[~,id] = min(dist);
   
   %[n ids] = sort(dist);

    predlabels(i) = gs.train_gs(id);
end

matches = find(predlabels == gs.test_gs(1:tcount)');

rate = 1 - numel(matches)/tcount;

end



function [h] = buildColorHist(img,numbins)
%  - numbins : number of bins
%  bins => bins with respective size per channel.
%  joint binning is used to compute all possible combination.

bsize = 256./numbins;

idx = cumprod([1 numbins]);
[h w ~] = size(img);

pxval = ones(h*w,1);

a = numbins(1);
b = a*numbins(2);
c = b*numbins(3);

%put in 0 255 scale
if ~strcmp(class(img), 'uint8'), 
    img = im2uint8(img); 
end

for i = 1:3
    im1 = double(img(:,:,i));
    im1 = reshape(im1,[h*w 1]);
    
    %bin index (bins from 0 to numbins-1)
    binnumber = floor(im1/bsize(i));
    
    %compute bin number 
    pxval = pxval + binnumber*idx(i);
end

%encoding all possible bin combinations for all 
%three channels and reajust it to 
hbin = hist(pxval,1:c) + 1;

%normalize
h = hbin/sum(hbin);

end

