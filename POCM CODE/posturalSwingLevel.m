function PSL = posturalSwingLevel(Skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PSL = posturalSwingLevel(Skeleton)
%% Extract the postural swing level
%%
%% Input:
%% Skeleton:  Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%%
%% Output:
%% PSL: postural swing level (standard variation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PSL = std( Skeleton(:,16));