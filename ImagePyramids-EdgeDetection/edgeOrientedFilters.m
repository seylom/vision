function bmap = edgeOrientedFilters(im)

%sigma = 1
[h w c] = size(im);
[mag theta] = orientedFilterMagnitude(im);

img_mag = sqrt(mag(:,:,1).*mag(:,:,1) + mag(:,:,2).*mag(:,:,2) + mag(:,:,3).*mag(:,:,3));

%compute orientation from channel with largest gradient.
[m_max idx] = max(mag,[],3);

theta_mag = zeros(h,w);

%storing orientation of channel with highest gradient magnitude.
for i=1:h
    for j=1:w
        theta_mag(i,j) = theta(i,j,idx(i,j));
    end
end

bmap = nonmax(img_mag,theta_mag); 
