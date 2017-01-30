function ali = dtw(Xs)
% Dynamic Time Warping (DTW).
%
% Input
%   Xs      -  sequences, 1 x 2 (cell), dim x ni
%
% Output
%   ali     -  alignment
%     P     -  warping path, n0 x 2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-09-2010
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

D = conDst(Xs{1}, Xs{2});
[v, S] = dtwFord(D);
P = dtwBack(S);

ali = newAli('P', P, 'obj', v);