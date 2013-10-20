%best setting : hr=5,hs=12,minimum number of pixels = 50
%best distance: 2*hssq,2*hrsq
%best cluster creation filters : hrsq and hssq as in the original paper. 
%best cluster creation elimination (optional step) : 5*hssq and 4*hrsq

%best setting : hr=5,hs=12,minimum number of pixels = 50
%best distance: 4*hssq,4*hrsq
%best cluster creation filters : hrsq and hssq as in the original paper. 
%best cluster creation elimination (optional step) : hssq and 3*hrsq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

im_1 = imread('house2.jpg');
im_2 = imread('lion.jpg');
%im_3 = imread('house_small.jpg');

meanshift_gauss(im_1,5,12,0.01,100);
meanshift_gauss(im_2,5,12,0.01,100);
%meanshift_gauss(im_3,12,3,0.01,10);