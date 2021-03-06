% function [v, S, DC] = dtwFord(D)
% Move forward to compute the objective value of DTW.
%
% There are two versions implemented with the same interface:
%   (1) matlab version: dtwFordSlow.m
%   (2) c++ version:    dtwFord.cpp
%
% Example
%   input   -  D = [0 1 1 1 0 1 1 0 1; ...
%                   1 0 1 1 1 1 1 1 0; ...
%                   1 1 0 1 1 1 1 1 1; ...
%                   1 1 1 0 1 0 0 1 1; ...
%                   1 1 1 0 1 0 0 1 1; ...
%                   0 1 1 1 0 1 1 0 1; ...
%                   1 0 1 1 1 1 1 1 0];
%   call    -  [v, P, U] = dtwFord(D)
%   output  -  v = 1;
%              S = [0 1 1 1 1 1 1 1 1; ...
%                   2 3 1 1 1 1 1 1 3; ...
%                   2 2 3 1 1 1 1 1 1; ...
%                   2 2 2 3 1 1 1 1 1; ...
%                   2 2 2 2 1 1 1 1 1; ...
%                   2 2 2 2 3 1 1 3 1; ...
%                   2 2 2 2 2 3 1 2 3]
%              DC = [0 1 2 3 3 4 5 5 6; ...
%                   1 0 1 2 3 4 5 6 5; ...
%                   2 1 0 1 2 3 4 5 6; ...
%                   3 2 1 0 1 1 1 2 3; ...
%                   4 3 2 0 1 1 1 2 3; ...
%                   4 4 3 1 0 1 2 1 2; ...
%                   5 4 4 2 1 1 2 2 1]
%
% Input
%   D       -  frame (squared) distance matrix, n1 x n2
%
% Output
%   v       -  objective value of dtw
%   S       -  step matrix, n1 x n2
%   DC      -  cummulative distance matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-03-2010
