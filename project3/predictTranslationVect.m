function [newX newY active] = predictTranslationVect(startX,startY,Ix,Iy,im0,im1)

active = 1;

window = 7;
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

yo = (floor(startY)-window):(ceil(startY)+window);
xo = (floor(startX)-window):(ceil(startX)+window);
[cx, cy] = meshgrid( startX-floor(startX)+(1:1:(d)), startY-floor(startY)+(1:1:(d)) );
[mx, my] = meshgrid( 1:numel(xo), 1:numel(yo) );

n_Ix = interp2( mx, my, Ix(yo, xo), cx, cy);
n_Iy = interp2( mx, my, Iy(yo, xo), cx, cy);

A = [ reshape(n_Ix, [1 d2]); reshape(n_Iy, [1 d2] ) ];
Io = reshape(interp2( mx, my, im0(yo, xo), cx, cy),  [1 d2]);

x1 = startX;
y1 = startY;

%fprintf('x1=%f and y1=%f \n',newX,newY);

idx = 0;

disp = 10*ones(2,1);
oldDisp = zeros(2,1);

maxiter = 20;
niter = 0;
while ((any(abs(disp-oldDisp)) > 0.001) && (niter < maxiter))
    niter = niter + 1;
    oldDisp = disp;
    
    inbound = ((floor(x1)-r)>0 & (floor(y1)-r)>0 & (ceil(x1)+r)<=w & (ceil(y1)+r)<=h);
    %ignore this point if its window will be too close to the border
    if  ~inbound
        %x1 = startX;
        %y1 = startY;
        %active = 0; % we lost the point.
        x1 = NaN;
        y1 = NaN;
        break
    end
    
    xIdx = (floor(x1)-r):(ceil(x1)+r);
    yIdx = (floor(y1)-r):(ceil(y1)+r);

%     Xc1 = wx + x1;
%     Yc1 = wy + y1;
%     n_I1 = interp2(im1,Xc1,Yc1);
% 
%     %recompute It
%     It = n_I1 - n_I0;
% 
%     
%     b1 = sum(sum(n_Ix.*It));
%     b2 = sum(sum(n_Iy.*It));  

    %This code section uses a trick I saw in the hw2 to vectorize
    [cordX, cordY] = meshgrid( x1-floor(x1)+(1:1:(d)), y1-floor(y1)+(1:1:(d)) );
    [meshX, meshY] = meshgrid( 1:numel(xIdx), 1:numel(yIdx) );

    R = reshape(interp2( meshX, meshY, im1(yIdx, xIdx), cordX, cordY),  [1 d2]);
    b = -(R - Io);
  
    %b = [b1 b2]';
    %get u and v
    %s = - inv(a)*b;
    %s = - a\b;
    
    s = pinv(A*A')* (A*b');

    u = s(1,1);
    v = s(2,1);

    %update coordinates with displacement.
    x1 = x1 + u;
    y1 = y1 + v;

    %check boundary conditions again to make sure we are still on the
    %image otherwise break out of the loop and return the starting point.
   
    %if we have done the loop about 5 times, exit
    %I am not checking here for convergence, but I could have combine both.
    %In the case were I would be using a threshold to determine convergence
    %we would only keep the value of the displacement that minimizes the
    %error. Finding a way to express that error was what I couldn't figure
    %out. A sum of square difference between the window of the current image 
    %being tracked and the predicted window after interpolation could be a
    %solution. I didn't implement it though.
%     if (j == 5)
%         if any((x1<7) || (x1> w-7) || (y1<7) || (y1>h-7))         
%             x1 = startX;
%             y1 = startY;
%             active = 0; % we lost the point.
%             break;
%         end
%        %update the next image point list with the 
%        %updated one for interpolation
%        break;
%     end

    idx = idx +1;
    
    disp = [u;v];
end


newX = x1;
newY = y1;