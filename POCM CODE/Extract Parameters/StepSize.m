function [L,R] = StepSize(Skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% [L,R] = StepSize(Skeleton)
%% Extract the left and right step size of a given skeleton sequence
%%
%% Input:
%% Skeleton:  Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%%
%% Output:
%% L, R: Left and right step sizes in mm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = abs( Skeleton(end, 12) - Skeleton(1, 12));
R = abs( Skeleton(end, 15) - Skeleton(1, 15));
