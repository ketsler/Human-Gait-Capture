function [ali, Ys] = aliDtwD(Xs)
% Derivative Dynamic Time Warping (DDTW).
%
% Input
%   Xs      -  original sequences, 1 x 2 (cell)
%
% Output
%   ali     -  alignment
%   Ys      -  new sequences, 1 x 2 (cell)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-16-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-08-2010

% derivative
Ys = cell(1, 2);
for i = 1 : 2
    Ys{i} = diff(Xs{i}, 1, 2);
    Ys{i} = [Ys{i}, Ys{i}(:, end)];
end

% dynamic time warping
ali = aliDtw(Ys);
