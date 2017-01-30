function WriteSkeleton(File_path, Skeleton_data, Platform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Usage
%% Write2File(File_path, Skeleton_data, Matching)
%%
%% Input:
%% File_path: the path of the file
%% Skeleton_data: Skeleton data to save
%% Platform:      Platform name, e.g. 'Microsoft Kinect SDK' or 'OpenNI/NITE'
%%
%% Example:
%% Write2File('C:\skeleton.txt', Skeleton_data, Matching)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nb_frame = size(Skeleton_data,1);
nb_joint = size(Skeleton_data,2)/3;
%% Open file to write data
fid = fopen(File_path, 'w');
fprintf(fid, '%s\n', Platform); %% Platform name
fprintf(fid, '%d\n', nb_frame); %% Total number of frames
fprintf(fid, '%d\n', nb_joint); %% Total number of joints per frame
%% Now start writing the files
for i=1:nb_frame
    fprintf(fid, '%d\n', i); %% frame index
    fprintf(fid, '%d\n', 1); %% only one skeleton
    for j=1:nb_joint
        fprintf(fid, '%f %f %f\n', Skeleton_data(i,j),... 
            Skeleton_data(i,j+nb_joint), Skeleton_data(i,j+2*nb_joint));
    end
end
fclose(fid);