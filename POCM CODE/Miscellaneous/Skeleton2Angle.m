function Skeleton_angle = Skeleton2Angle(Skeleton_data, List)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% Skeleton_angle = Skeleton2Angle(Skeleton_data, List)
%%
%% Input:
%% Skeleton_data:  N*M matrix, N is the total number of frame, M = 3*dim,
%% each row [x,...,x,y,...,y,z,...,z]
%% List:           L*2 matrix, L is the total number of edges, each row 
%% has the corresponding indexes of the edge
%%
%% Output:
%% Skeleton_angle: N*(3+3*L) matrix, N is the total number of frame, each
%% row has a root and then normalized direction of edge [x,y,z,...,x,y,z]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Step 1: Initialize matrix
N = size(Skeleton_data,1);  %%total number of frame
L = size(List,1);           %%total number of edge
D = size(Skeleton_data,2)/3;%%total number of joints per frame
root = List(1,1);
Skeleton_angle = zeros(N, 3+3*L);
%%Step 2: Obtain the root
for i=1:3
    Skeleton_angle(:,i) = Skeleton_data(:,root+(i-1)*D);
end
%%Step 3: Calculate the angle per edge
for i=1:L
    s_ind = List(i,1); %%source index
    t_ind = List(i,2); %%target index
    Direction = [Skeleton_data(:,t_ind) - Skeleton_data(:,s_ind),...
        Skeleton_data(:,t_ind+D) - Skeleton_data(:,s_ind+D),...
        Skeleton_data(:,t_ind+2*D)-Skeleton_data(:,s_ind+2*D)];
    Norm = sqrt(Direction(:,1).*Direction(:,1) +...
        Direction(:,2).*Direction(:,2) +...
        Direction(:,3).*Direction(:,3));
    for j=1:3
        Skeleton_angle(:,3*i+j) = Direction(:,j)./Norm; %%normalize the vector
    end
end