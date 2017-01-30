function D = conDst(X1, X2, varargin)
% Compute distance matrix.
%
% Input
%   X1      -  1st sample matrix, dim x n1
%   X2      -  2nd sample matrix, dim x n2
%   varargin
%     dst   -  distance type, {'e'} | 'b'
%              'e': Euclidean distance
%              'b': binary distance
%
% Output
%   D       -  squared distance matrix, n1 x n2
%              If nargout == 0, then put the distance matrix as a global variable.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-24-2010

% global
global DG;
isDG = nargout == 0;

% function option
dst = ps(varargin, 'dst', 'e');

% dimension
n1 = size(X1, 2);
n2 = size(X2, 2);
if size(X1, 1) == 1
    X1 = [X1; zeros(1, n1)]; 
    X2 = [X2; zeros(1, n2)]; 
end
XX1 = sum(X1 .* X1); XX2 = sum(X2 .* X2); 

% compute
if isDG
    DG = -2 * X1' * X2;
    for i2 = 1 : n2
        DG(:, i2) = DG(:, i2) + XX1';
    end
    for i1 = 1 : n1
        DG(i1, :) = DG(i1, :) + XX2;
    end
else
    X12 = X1' * X2;
    D = repmat(XX1', [1 n2]) + repmat(XX2, [n1 1]) - 2 * X12;
end

% Euclidean distance
if strcmp(dst, 'e')

% binary distance
elseif strcmp(dst, 'b')
    if isDG
        DG = real(DG > 1e-8);
    else
        D = real(D > 1e-8);
    end

else
    error(['unknown distance type: ' dst]);
end
