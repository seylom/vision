function graphcut_segmentation_cat()

img0 = im2double(imread('cat.jpg'));

cform = makecform('srgb2lab');
img = applycform(img0,cform);
%img = rgb2luv(img);
%img = rgb2Lab(img0);



[h w ~] = size(img);
imgr = img(:,:,1);
imgg = img(:,:,2);
imgb = img(:,:,3);

imtest = zeros(h,w,3);

imgData = [imgr(:) imgg(:) imgb(:)];

data = load('cat_poly.mat');
d = data.poly;
msk = poly2mask(d(:,1),d(:,2),w,h);
imMask = reshape(msk,w*h,1);

fgIdx = imMask' == 1;
bgIdx = imMask' == 0;

fg_data = imgData(fgIdx,:);
bg_data = imgData(bgIdx,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  fitting foreground and background with gaussian mixture models
K1 = 1;

K2 = 1;
options = statset('Display','final');

% fgm = gmdistribution.fit(fg_data(:,1),K1,'Options',options);
% fgm = gmdistribution.fit(fg_data(:,2),K1,'Options',options);
% fgm = gmdistribution.fit(fg_data(:,3),K1,'Options',options);
% 
% bgm = gmdistribution.fit(bg_data(:,1),K2,'Options',options);
% bgm = gmdistribution.fit(bg_data(:,2),K2,'Options',options);
% bgm = gmdistribution.fit(bg_data(:,3),K2,'Options',options);

%likelihood given pixel estimated with the model for each channel
%separately

p_fg = zeros(size(imgData,1),3);
p_bg = zeros(size(imgData,1),3);

for i =1:3
    fgm = gmdistribution.fit(fg_data(:,i),K1,'Options',options);
    p_fg(:,i) = pdf(fgm,imgData(:,i));
    
    bgm = gmdistribution.fit(bg_data(:,i),K2,'Options',options);
    p_bg(:,i) = pdf(bgm,imgData(:,i));
end

imgfg = zeros(size(p_fg));
imgbg = zeros(size(p_fg));

imgfgMap = zeros(size(p_fg));

res_fg = zeros(size(imgData,1),1);
res_bg = zeros(size(imgData,1),1);

[res_fg ~]= max(p_fg,[],2);
[res_bg ~] = max(p_bg,[],2);


fg = p_fg(:,1).*p_fg(:,2).*p_fg(:,3);
bg = p_bg(:,1).*p_bg(:,2).*p_bg(:,3);

fg = reshape(fg, [h w]);
bg = reshape(bg, [h w]);

for i=1:3
%   imgfg(:,i) = p_fg(:,1)>p_bg(:,1) & p_fg(:,2)>p_bg(:,2) & p_fg(:,3)>p_bg(:,3);   
%   imgbg(:,i) = p_fg(:,1)<p_bg(:,1) | p_fg(:,2)<p_bg(:,2) | p_fg(:,3)<p_bg(:,3);
  
  imgfg(:,i) = res_fg > res_bg;
  imgbg(:,i) = res_bg > res_fg;
end

for i=1:3
   imgfgMap(:,i) = p_fg(:,i)>p_bg(:,i); 
end

%foreground or background
% res_fg(:) =  p_fg(:,1)>p_bg(:,1) & p_fg(:,2)>p_bg(:,2) & p_fg(:,3)>p_bg(:,3);
% res_bg(:) = p_fg(:,1)<p_bg(:,1) | p_fg(:,2)<p_bg(:,2) | p_fg(:,3)<p_bg(:,3);

fg_resImg = zeros(size(img0));
bg_resImg = zeros(size(img0));

fg_resImgMap = zeros(size(img0));
for i=1:3
   fg_resImgMap(:,:,i) = reshape(imgfgMap(:,i), [h w]); 
end

for i=1:3
   fg_resImg(:,:,i) = reshape(imgfg(:,i), [h w]); 
   bg_resImg(:,:,i) = reshape(imgbg(:,i), [h w]); 
end


res_fg = reshape(res_fg, [h, w]);
res_bg = reshape(res_bg, [h, w]);

figure(1),imshow(fg_resImg);
figure(2),imshow(bg_resImg);
figure(3),imshow(fg_resImgMap);

%defining our unary terms for the Energy
%logfg = -log(res_fg);
%logbg = -log(res_bg);

logfg = -log(fg);
logbg = -log(bg);

DataCost = cat(3,logfg,logbg);
SmoothnessCost = [0 1;1 0];

[gch] = GraphCut('open', DataCost, SmoothnessCost);

[gch labels] = GraphCut('swap', gch);

fglabels = ~logical(labels);
bglabels = ~fglabels;

labelMap = cat(3, fglabels, fglabels, fglabels);

resultImg = zeros(h,w,3) + img.*labelMap;

bglabelmap = ~labelMap;



cform2 = makecform('lab2srgb');
resultImg = applycform(resultImg,cform2);

resultImg(:,:,3) = resultImg(:,:,3) +  (255*ones(h,w,1)).*bglabelmap(:,:,1) ;

%resultImg(:,:,3) = resultImg(:,:,3) + ones([h w]).*bglabels;
%resultImg = luv2rgb(resultImg);
figure(4),imshow(resultImg);

%GraphCut(gch,'close');


end