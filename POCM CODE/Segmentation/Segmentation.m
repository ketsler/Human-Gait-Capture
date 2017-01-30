function [SkeletonS, Seg] = Segmentation(SkeletonW)    %%, fHandle, MHandle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SkeletonS = Segmentation(SkeletonW, fHandle)
%% Segment SkeletonW into multiple repeated SkeletonS
%%
%% Input:
%% SkeletonW: Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%% fHandle:   Handle to a feature function that maps each skeleton to a feature
%% Mhandle:   Handle to a mask function that checks the validity of each skeleton
%%
%% Output:
%% SkeletonS: A cell, containing K segmented skeletal sequences
%% Seg:       K*2 matrix, [e1,b1;e2,b2;...;eK,bK] with ei and bi the starting
%% and ending index of ith segmented skeletal sequence
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step1: Project high dimensional skeletal data to 1D feature space
F = FeetDistance(SkeletonW);%%fHandle(SkeletonW);

%% Step2: Obtain the validity mask
V = 1;%%WalkingBackwardY(SkeletonW);%%MHandle(SkeletonW);
F = F.*V;

%% Step3: Find the local minimum
Opt = [];
for i=2:length(F)-1
    if( F(i) > F(i-1) && F(i) > F(i+1) && F(i-1) ~= 0 && F(i+1) ~= 0)
        if( SkeletonW(i,27) > SkeletonW(i,30) )
            Opt = [Opt, i];
        else
            Opt = [Opt,-i];
        end
    end
end

%% Step4: Find the segmentation
Seg = [];
for i=1:length(Opt)-2
    if( Opt(i) > 0 && Opt(i+1) < 0 && Opt(i+2) > 0 && Opt(i+2)-Opt(i) < 60 &&...
        Opt(i+2)-Opt(i) > 20)
        Seg = [Seg;Opt(i), Opt(i+2)];
    end
end

%% Step5: Get the segmented skeletal sequences
for i=1:size(Seg,1)
    SkeletonS{i} = SkeletonW(Seg(i,1):Seg(i,2),:);
end
