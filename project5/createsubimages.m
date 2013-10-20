function [imgs] = createsubimages(im,levels)
%   creates all patches based on the number of levels.
%   -im: the image
%   -levels: the number of levels
%   -imgs=> the cell array of image patches created.

imgs{1} = im;

for i = 1:levels
    numimg = size(imgs,1);
    
    idx = 1;
    subs = cell(numimg*4,1);
    
    for j = 1:numimg
        im1 = imgs{i};
        [h w ~] = size(im1);
        
        a1 = floor(h/2);
        b1 = floor(w/2);

        ima = im(1:a1,1:b1,:);
        imb = im(1:a1,b1+1:w,:);
        imc = im(a1+1:h,1:b1,:);
        imd = im(a1+1:h,b1+1:w,:);
        
        subs{idx} = ima;
        subs{idx+1} = imb;
        subs{idx+2} = imc;
        subs{idx+3} = imd;
        
        idx = idx+4;
    end
    
    imgs = subs;
end

end
