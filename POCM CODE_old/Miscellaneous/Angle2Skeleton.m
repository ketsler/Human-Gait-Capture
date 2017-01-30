function Skeleton_data = Angle2Skeleton(Skeleton_angle, List, Bone)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% Skeleton_data = Angle2Skeleton(Skeleton_angle, List, Bone)
%%
%% Input:
%% Skeleton_angle: N*(3+3*L) matrix, N is the total number of frame, each
%% row has a root and then normalized direction of edge [x,y,z,...,x,y,z]
%% 
%% List:           L*2 matrix, L is the total number of edges, each row 
%% has the corresponding indexes of the edge
%% Bone:           L vector, each value is the corresponding length of edge
%% in mm
%%
%% Output:
%% Skeleton_data:  N*M matrix, N is the total number of frame, M = 3*dim,
%% each row [x,...,x,y,...,y,z,...,z]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Step 1: Initialize matrix
N = size(Skeleton_angle,1);  %%total number of frame
L = size(List,1);            %%total number of edge
D = L+1;                     %%total number of joints per frame
root = List(1,1);
Skeleton_data = zeros(N, 3*D);
%%Step 2: Obtain the root
for i=1:3
    Skeleton_data(:,root+(i-1)*D) = Skeleton_angle(:,i); 
end
%%Step 3: Calculate for each angle
for i=1:L
    s_ind = List(i,1); %%source index
    t_ind = List(i,2); %%target index
    for j=1:3
       Skeleton_data(:,t_ind+(j-1)*D) = Skeleton_data(:,s_ind+(j-1)*D) + ...
           Skeleton_angle(:,3*i+j)*Bone(i);
    end
end