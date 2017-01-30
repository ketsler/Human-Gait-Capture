function p = tranTemLn(n0s, ns)
% Generate parameter of temporal transformation.
%
% Input
%   n0s     -  original segment lengths, 1 x m
%   ns      -  new segment lengths, 1 x m
%
% Output
%   p       -  warping path vector, n x 1
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-05-2010

m = length(n0s);
n = sum(ns);

p = zeros(n, 1);
head0 = 0;
head = 0;
for i = 1 : m
    idx = 1 : ns(i);
    p(head + idx) = head0 + round(n0s(i) / ns(i) * idx');
    head0 = head0 + n0s(i);
    head = head + ns(i);
end
