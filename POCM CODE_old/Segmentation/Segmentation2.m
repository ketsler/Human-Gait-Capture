function [SkeletonS, Seg] = Segmentation2(SkeletonW, MHandle1, MHandle2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SkeletonS = Segmentation(SkeletonW, fHandle)
%% Segment SkeletonW into multiple repeated SkeletonS
%%
%% Input:
%% SkeletonW: Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%% MHandle1:   Handle to a mask function that checks the validity of each skeleton
%% Mhandle2:   Handle to a mask function that checks the validity of each skeleton
%%
%% Output:
%% SkeletonS: A cell, containing K segmented skeletal sequences
%% Seg:       K*2 matrix, [e1,b1;e2,b2;...;eK,bK] with ei and bi the starting
%% and ending index of ith segmented skeletal sequence
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step1: Project high dimensional skeletal data to 1D feature space
M1 = MHandle1(SkeletonW);

%% Step2: Obtain the validity mask
M2 = MHandle2(SkeletonW);
M = M1.*M2;

%% Step3: Find the local minimum
Opt = [];
for i=2:length(M)
    if( M(i)>0 && M(i-1)==0)
        Opt = [Opt; i];
    end
end

%% Step4: Find the segmentation
Seg = [];
for i=1:length(Opt)-1
    Seg = [Seg;Opt(i), Opt(i+1)];
end

%% Step5: Get the segmented skeletal sequences
for i=1:size(Seg,1)
    SkeletonS{i} = SkeletonW(Seg(i,1):Seg(i,2),:);
end
