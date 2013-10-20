function [newX newY active] = predictTranslation(startX,startY,Ix,Iy,im0,im1)

[h w] = size(im0);

active = 1;

%precompute the grid for interpolation 
[Xpi Ypi] = meshgrid(startX-7:startX+7,startY-7:startY+7);

%window neighbourhoods
n_I0 = interp2(im0,Xpi,Ypi);
n_Ix = interp2(Ix,Xpi,Ypi);
n_Iy = interp2(Iy,Xpi,Ypi);

a1 = sum(sum(n_Ix.*n_Ix));
a2 = sum(sum(n_Ix.*n_Iy));
b2 = sum(sum(n_Iy.*n_Iy));

a = [a1 a2;a2 b2];

x1 = startX;
y1 = startY;

%fprintf('x1=%f and y1=%f \n',newX,newY);

idx = 0;

disp = 10*ones(2,1);
oldDisp = zeros(2,1);

maxiter = 200;
niter = 0;
while ((any(abs(disp-oldDisp)) > 0.01) && (niter < maxiter))
    niter = niter + 1;
    oldDisp = disp;
    
    %ignore this point if its window will be too close to the border
    if (x1 < 7 || x1 > w-7 || y1 < 7 || y1 > h-7) 
        x1 = startX;
        y1 = startY;
        active = 0; % we lost the point.
        break
    end

    n_I1 = interp2(im1,Xpi,Ypi);

    %recompute It
    It = n_I1 - n_I0;

    b1 = sum(sum(n_Ix.*It));
    b2 = sum(sum(n_Iy.*It));
    b = [b1 b2]';

    %get u and v
    %s = - inv(a)*b;
    s = - a\b;

    u = s(1,1);
    v = s(2,1);

    %update coordinates with displacement.
    Xpi = Xpi + u;
    Ypi = Ypi + v;

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