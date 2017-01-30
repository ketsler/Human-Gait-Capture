function Dis = SkeletonDistance(Skeleton1, Skeleton2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% Dis = SkeletonDistance(Skeleton1, Skeleton2)
%%
%% Input:
%% Skeleton1: First Skeleton Data
%% Skeleton2: Second Skeleton Data
%%
%% Output:
%% Dis: Distance between the two skeleton data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Dis = sum(sum( abs(Skeleton1-Skeleton2),2))/size(Skeleton1,1);