function [C, C1] = aliUnif(xHd, xTl)
% Uniformly warp one sequence towards two the other one.
%
% Input
%   xHd     -  head position, 2 x 1
%              if only one parameter, xhead = [1; 1];
%   xTl     -  tail position, 2 x 1
%
% Output
%   C       -  correspondance matrix, 2 x nC
%   C1      -  correspondance matrix, 2 x (nC - 2)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-11-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 02-23-2010

% one parameter
if nargin == 1
    xTl = xHd;
    xHd = [1; 1];
end
xGap = xTl - xHd + 1;
n1 = xGap(1); n2 = xGap(2);

if n1 > n2
    [C, C1] = scaleWarp(xHd([2 1]), xTl([2 1]));
    C = C([2 1], :);
    C1 = C1([2 1], :);
    return;
end

js = 1 : n2;
if n2 == 1
    vs = (n1 - 1) * (js - 1) / n2 + 1;
else
    vs = (n1 - 1) * (js - 1) / (n2 - 1) + 1;
end
is = round(vs);
C = [is; js] + repmat(xHd, 1, n2) - 1;
C1 = C(:, 2 : end - 1);
