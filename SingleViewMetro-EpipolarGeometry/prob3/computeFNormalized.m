function [F1 T1 T2] = computeFNormalized(b1,b2)

[T1 b1]= normalizepoints(b1);
[T2 b2]= normalizepoints(b2);

b1 =  b1';
b2 =  b2';

A = [b2(:,1).*b1(:,1) b2(:,1).*b1(:,2) b2(:,1) b2(:,2).*b1(:,1) b2(:,2).*b1(:,2) b2(:,2) b1(:,1) b1(:,2) ones(size(b1,1),1) ];

%using singular value decomposition to solve A
[U, S, V] = svd(A);
f = V(:, end); 
F1 = reshape(f, [3 3])';

%enforcing the det(F) = 0 constraint.
[U, S, V] = svd(F1); 
S(3,3) = 0; 
F1 = U*S*V';