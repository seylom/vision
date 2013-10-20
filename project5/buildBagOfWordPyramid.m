function [levels] = buildBagOfWordPyramid(im,numlevels,siftpositions,siftvectors,clusters,vocabulary)
% builds spatial pyramid
%   - im the image
%   - numlevels: the number of levels (numlevels = 1 is the whole image histogram)
%   - the position of our sift vector
%   - clusters: the cluster points.
%   - siftvectors: the list of sift vectors for the image.
%   - the vocabulary.

levelcount = numlevels-1;

imlist = createsubimages(im,levelcount);
numimg = size(imlist,1);

h=cell(numimg,1);

for i=1:numimg
    h{i} = WordHist(imlist{i},siftpositions,siftvectors,clusters,vocabulary);
end

levels = cell(levelcount,1);

%combine levels by summing subpatches of patches for each level
for i = 0:levelcount
    j = i;
    k = 4^j;
    hcount = floor(numimg/k);
    
    hct = cell(hcount,1);
    
    idk = 1;

    for m = 1:hcount
        r = zeros(size(h{1}));
        for n = 1:k 
            r = r + h{idk};
            idk = idk +1;
        end
        hct{m} = r;
    end    
    
    levels{levelcount +1 - i}  = hct;
end

end


function  h = wordHist(img,siftpositions,siftvectors,clusters,vocabsize)
% returns a bag of word vector associated to the image

h = zeros(1,vocabsize);

numsift = size(siftpositions,1);
[h w c] = size(img);

for i=1:numsift
    s1 = siftpositions(i,:);
    x = s1(1,:);
    y = s1(2,:);
    
    d1 = siftvectors(i,:);
    
    if (x>0 && x <=w && y> 0 && y<= h)
        
        dist = sum(abs(clusters - repmat(d1,[])));
        [~,idx] = min(dist);
        h(idx)= v(idx) +1;
        
    end
end

end