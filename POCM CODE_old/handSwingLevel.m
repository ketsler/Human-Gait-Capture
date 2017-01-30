function [L,R] = handSwingLevel(Skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% [L,R] = handSwingLevel(Skeleton)
%% Extract the swing level of both hands
%%
%% Input:
%% Skeleton:  Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%%
%% Output:
%% [L, R]: Swing level of left and right hand (standard deviation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = std( Skeleton(:,6)-Skeleton(:,1));
R = std( Skeleton(:,9)-Skeleton(:,1));