function [Skeleton_data, List] = LoadSkeleton(File_path, Type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% [Skeleton_data, List] = ParseFile(File_path, Type)
%%
%% Input:
%% File_path: the path of the file
%% Type:      different types of data
%%   Type = 1:    Microsoft SDK 20 Joints
%%   Type = 2:    OpenNI/NITE 15 Joints
%%   Type = 3:    Microsoft SDK 15 Joints
%%
%% Output:
%% Skeleton_data: A M*N matrix, where M is the number of frames, and N 
%% = 3 * #_joints
%% List:      Indicates the connectivity of the graph
%%
%% Example:
%% [Skeleton_data, List] = ParseFile('C://skeleton.txt', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Step 1: Parse the file
fid = fopen(File_path, 'r');
fgetl(fid); % Platform (useless)
nb_frames = str2double(fgetl(fid)); % Total number of frames
fgetl(fid); % Dimensionality (useless)
global nb_joint;
if( Type == 1)
    nb_joint = 20;
    Skeleton_data = zeros(nb_frames, 3*nb_joint);
elseif( Type == 2)
    nb_joint = 15;
    Skeleton_data = zeros(nb_frames, 3*nb_joint);
elseif( Type == 3)
    nb_joint = 15;
    Skeleton_data = zeros(nb_frames, 3*nb_joint);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2: Read the data in
for i=1:nb_frames
    fgetl(fid);fgetl(fid); % frame index and number of skeleton (useless)
    temp = fscanf(fid,'%f\n',[1 3*nb_joint]);
    Skeleton_data(i,:) = [temp(1:3:1+3*(nb_joint-1)),...
        temp(2:3:2+3*(nb_joint-1)),temp(3:3:3+3*(nb_joint-1))];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 3: Update List
if( Type == 1)
    List = [1, 2; 2, 3; 3, 4; 3, 5; 5, 6; 6, 7; 7, 8; 3, 9; 9, 10; 10, 11; 11, 12;...
        1, 13; 13, 14; 14, 15; 15, 16; 1, 17; 17, 18; 18, 19; 19, 20];
elseif( Type == 2)
    List = [3, 2;2, 1; 2, 4; 2, 7; 4, 5; 5, 6; 7, 8; 8, 9; 3, 10; 10, 11;...
        11, 12; 3, 13; 13, 14; 14, 15];
elseif( Type == 3)
    List = [1, 2; 2, 3; 2, 4; 4, 5; 5, 6; 2, 7; 7, 8; 8, 9;...
        1, 10; 10, 11; 11, 12; 1, 13; 13, 14;14, 15];
end
fclose(fid);   