function shPtUpd(h, x)
% Show one point in the 2-D figure.
%
% Input
%   h       -  original figure content handle
%   x       -  point position, 1 x 2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-03-2010
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-16-2010

set(h, 'XData', x(1), 'YData', x(2));
