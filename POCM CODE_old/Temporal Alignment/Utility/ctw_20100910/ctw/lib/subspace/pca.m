function [Y, lam, V, mu] = pca(X, dim)
% Principal Componant Analysis (PCA).
%
% Input
%   X       -  sample matrix, dim0 x n
%
% Output
%   Y       -  principal components, dim x n
%   lam     -  sorted lambda (eigenvalue), dim x 1
%   V       -  principal directions, dim0 x dim
%   mu      -  mean vector of X, dim0 x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-30-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-31-2010

% dimension
[dim0, n] = size(X);

% subtract the mean
mu = sum(X, 2) / n;
X = X - repmat(mu, 1, n);

% svd decomposition
[U, S] = svd(X, 0);
[lam, idx] = sort(sum(S, 2), 'descend');
V = U(:, idx);

Y = V' * X;

if exist('dim', 'var')
    Y = Y(1 : dim, :);
    lam = lam(1 : dim);
    V = V(:, 1 : dim);
end
