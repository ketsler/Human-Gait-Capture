function As = cellDec(A, ns)
% Decompose the matrix into small ones.
%
% Example
%   Input   -  A = [1 3 4 3 1 4; ...   ns = [4 2];
%                   1 3 3 2 4 5]
%   Call    -  As = cellDec(A, ns)
%   Output  -  As = {[1 3 4 3; 1 3 3 2], [1 4; 4 5]}
%
% Input
%   A       -  original matrix, dim x n
%   ns      -  part size, 1 x m
%
% Output
%   As      -  part set, 1 x m (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-06-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-14-2010

m = length(ns);

As = cell(1, m);

p = 0;
for i = 1 : m
    As{i} = A(:, p + 1 : p + ns(i));
    p = p + ns(i);
end
