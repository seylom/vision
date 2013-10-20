function F = computeransac(x1, x2)

e = .50; % 50% of outliers maybe          
p = .95;
s = 8;
N = log(1 - p)/log(1 - (1 - e)^s);
threshold = 3; % 3pixels

bestcount = 0;
inliers = zeros(size(x1));

for k = 1:N
    rp = randperm(size(x1,1));
    tx1 = x1(rp,:);
    tx2 = x2(rp,:);
    
    a1 =  tx1(1:8,:);
    a2 =  tx2(1:8,:);
    
    [F1 T1 T2] = computeFNormalized(a1,a2);

    F1 = T2'*F1*T1;
    
    d1 = F1*[a1(1,:) 1]';
    d2 = F1'*[a2(1,:) 1]';
    
    %err = sum(sqrt(d1(1,:).^2 + d2(1,:).^2));
    
    nin = sum(abs(sqrt(d1(1,:).^2 + d2(1,:).^2))<threshold);
    
    if nin > bestcount
        bestcount = nin;
        %inliers = abs(y(:,2) - V(:,2)) < thresh;
    end
end

xa = [x1 inliers];
ya = [x2 inliers];

c = xa(xa(:,3) == 1,1:2);
d = ya(ya(:,3) == 1,1:2);

[Fnorm T1 T2] = computefundNorm(c,d);
F = T2'*Fnorm*T1;