function [newX newY active] = shi_tomasi_affine_verification(startX,startY,Ix1,Iy1,im0,im1,upNewX,upNewY)

active = 1;

r = 7;
d = r*2+1;
d2 = d^2;

[h,w] = size(im0);
%[wx,wy]  = meshgrid(-7:1:7);

% %window neighbourhoods
% n_I0 = interp2(im0,Xpi,Ypi);
% n_Ix = interp2(Ix,Xpi,Ypi);
% n_Iy = interp2(Iy,Xpi,Ypi);
%    
% a1 = sum(sum(n_Ix.*n_Ix));
% a2 = sum(sum(n_Ix.*n_Iy));
% b2 = sum(sum(n_Iy.*n_Iy));
% 
% a = [a1 a2;a2 b2];

x = startX;
x2 = x^2;
y = startY;
y2 = y^2;

gx = Ix1(:,:);
gx2 = gx^2;

gy = Iy1(:,:);
gy2 = gy^2;

yo = (floor(startY)-r):(ceil(startY)+r);
xo = (floor(startX)-r):(ceil(startX)+r);
[cx, cy] = meshgrid( startX-floor(startX)+(1:1:(d)), startY-floor(startY)+(1:1:(d)) );
[mx, my] = meshgrid( 1:numel(xo), 1:numel(yo) );


dxx = 0;
dxy = 0;
dyx = 0;
dyy = 0;
dx = 0;
dy = 0;

zt = [dxx dyx dxy dyy dx dy];
z = zt';

U = [x2*gx2      x2*gx*gy    x*y*gx2      x*y*gx*gy; ...
     x2*gx*gy    x2*gy2      x*y*gx*gy    x*y*gy2;   ...
     x*y*gx2     x*y*gx*gy   y2*gx2       y2*gx*gy; ...
     x*y*gx*gy   x*y*gy2     y2*gx*gy     y2*gy2];

VTrans = [x*gx2  x*gx*gy  y*gx2  y*gx*gy; ...
     x*gx*gy   x*gy2   y*gx*gy   y*gy2 ];
 
V = VTrans';

Z = [gx2 gx*gy; ...
     gx*gy gy2];
 
T = [U V; ...
      VTrans Z];


x1 = 0;
y1 = 0;

maxiter = 20;
niter = 0;
while ((any(abs(disp-oldDisp)) > 0.001) && (niter < maxiter))
    niter = niter + 1;
    oldDisp = disp;
    
    inbound = ((floor(x1)-r)>0 & (floor(y1)-r)>0 & (ceil(x1)+r)<=w & (ceil(y1)+r)<=h);

    s = pinv(A*A')* (A*b');

    u = s(1,1);
    v = s(2,1);

    %update coordinates with displacement.
    x1 = x1 + u;
    y1 = y1 + v;

    idx = idx +1;
    
    disp = [u;v];
end


newX = x1;
newY = y1;