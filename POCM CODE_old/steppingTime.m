function T = steppingTime(Skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% T = steppingTime(Skeleton)
%% Extract the stepping time of two steps
%%
%% Input:
%% Skeleton:  Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%%
%% Output:
%% T: Steppin time in s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T = size(Skeleton,1)/30;