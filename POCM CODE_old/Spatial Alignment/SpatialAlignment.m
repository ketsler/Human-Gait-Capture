function Skeleton2 = SpatialAlignment(Skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Skeleton2 = SpatialAlignment(Skeleton)
%% Spatially align the Skeleton sequence to a normalized coordinate system
%%
%% Input:
%% Skeleton:  Whole skeletal sequence, N*M matrix, N is the total number of
%% frames and M is the dimension of each frame
%%
%% Output:
%% Skeleton2: Spatially aligned whole skeletal sequence, N*M matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step1: Find the translation vector
M = size(Skeleton,2);
t = -[Skeleton(1,1), Skeleton(1,1+M/3), Skeleton(1,1+M/3*2)]';

%% Step2: Find the rotation matrix
%% line fitting on x,y projection
p = polyfit( Skeleton(:,1), Skeleton(:,1+M/3), 1);
theta = asin( p(1)/(1+p(1)^2).^(1/2));
if theta > 0
    theta = pi+theta;
end
R = [cos(theta),sin(theta),0;-sin(theta),cos(theta),0;0,0,1];

%% Step3: Apply transformation
%% transform skeleton to points
pts = [reshape(Skeleton(:,1:M/3)',1,[]); reshape(Skeleton(:,M/3+1:2*M/3)',1,[]);reshape(Skeleton(:,2*M/3+1:M)',1,[])];
%% transform the points
pts = R*(pts + repmat(t, 1, size(pts,2)));
%% transform points back to skeleton
Skeleton2 = [reshape(pts(1,:),M/3,[])',reshape(pts(2,:),M/3,[])',reshape(pts(3,:),M/3,[])'];