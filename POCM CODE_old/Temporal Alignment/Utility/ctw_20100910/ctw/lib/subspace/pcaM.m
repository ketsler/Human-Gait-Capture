function Xs = pcaM(X0s, dim)
% Principal Componant Analysis (PCA) on multiple sample matrices.
%
% Input
%   X0s     -  original set of sample matrices, 1 x m, dim0 x ni
%   dim     -  dimensionality after projection
%
% Output
%   Xs      -  original set of sample matrices, 1 x m, dim x ni
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 09-12-2010
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-31-2010

% dimension
m = length(X0s);
dim0 = size(X0s{1}, 1);
if dim0 == dim
    Xs = X0s;
    return;
elseif dim0 < dim
    error('not enough dimension');
end
ns = cellDim(X0s, 2);
s = n2s(ns);

% concate
X0 = cat(2, X0s{:});

% pca
Comp = pca(X0);
X = Comp(1 : dim, :);

% split
Xs = cell(1, m);
for i = 1 : m
    Xs{i} = X(:, s(i) : s(i + 1) - 1);
end
