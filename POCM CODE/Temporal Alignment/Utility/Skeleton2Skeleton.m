function [Skeleton_data_2] = Skeleton2Skeleton(Skeleton_data_1, Matching)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% [Skeleton_data_2] = Skeleton2Skeleton(Skeleton_data_1, Matching)
%%
%% Input:
%% Skeleton_data_1: Original Skeleton data
%% Matching:        Matching list after DMW
%%
%% Output:
%% Skeleton_data_2: The output skeleton data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Skeleton_data_2 = zeros(length(Matching), size(Skeleton_data_1,2));
for i=1:length(Matching)
    Skeleton_data_2(i,:) = Skeleton_data_1(Matching(i),:);
end