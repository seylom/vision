function [levels] = buildPyramid(im,numlevels,numbins)
% builds spatial pyramid
%   - im the image
%   - numlevels: the number of levels (numlevels = 1 is the whole image histogram)
%   - numbins: the number of bins per levels.

levelcount = numlevels-1;

imlist = createsubimages(im,levelcount);
numimg = size(imlist,1);

h=cell(numimg,1);

for i=1:numimg
    h{i} = simpleColorHist(imlist{i},numbins);
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