function L = lapl(n)
% Obtain the Laplacian matrix used for computing derivative.
% The output L is a difference matrix such that:
%   X * L == [zeros(dim, 1), diff(X, 1, 2)];
%
% Input
%   n       -  matrix size
%
% Output
%   L       -  Laplacian matrix, n x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-18-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-31-2010

L = eye(n);
for i = 1 : n - 1
    L(i, i + 1) = -1;
end
% L(n, 1) = -1;
L(1) = 0;
