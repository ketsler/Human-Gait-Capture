function Y = embed(alg, X, G, dim, varargin)
% Embed samples according to the specific algorithm.
%
% Input
%   alg     -  algorithm type, 'pca' | 'lda' | 'kpca' | 'mds' | 'lle' | 'sc'
%   X       -  original sample matrix, dim0 x n
%   G       -  class indicator matrix, k x n
%   dim     -  dimensions after projection
%
% Output
%   Y       -  new sample matrix, dim x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-25-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-31-2010

if strcmp(alg, 'pca')
    Comp = pca(X);
    Y = Comp(1 : dim, :);

elseif strcmp(alg, 'lda')
    Comp = lda(X, G);
    Y = Comp(1 : dim, :);
    
elseif strcmp(alg, 'qda')
    ind = qda(X, G);
    Comp = X(ind, :);
    Y = Comp(1 : dim, :);    

elseif strcmp(alg, 'kpca')
    Y = kpca(X, dim);

elseif strcmp(alg, 'sc')
    [Htmp, Y] = sc(X, dim);

elseif strcmp(alg, 'mds')
    Y = mds(X, dim, varargin{:});

elseif strcmp(alg, 'lle')
    Y = lle(X, dim, varargin{:});

else
    error(['unknown embedding algorithm: ' alg]);
end
