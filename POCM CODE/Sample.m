%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sample code demonstrating the complete pipeline

close all; clear all; clc;

%% Add path 
addPathTASS;

%% Select the path 
subject_id = 5;
state_id = 0;
task_id = 3;
rep_id = 1;

input_filename = 'siddhantTraining2.txt';

%% Load the skeletal data
[SkeletonW, List] = LoadSkeleton(input_filename, 3);
%% Segment the data into two steps 
[SkeletonS, Seg] = Segmentation(SkeletonW);%%, @FeetDistance, @WalkingBackwardY);
nb_SAU = length(SkeletonS);

%% Spatial Alignment
for i=1:nb_SAU
    SkeletonS{i} = SpatialAlignment(SkeletonS{i});
end

%% Pick the reference SAU
temporal_score = zeros(nb_SAU, nb_SAU);
spatial_score = zeros(nb_SAU, nb_SAU);
for i=1:nb_SAU
    for j=1:nb_SAU
        [Matching, matchingDisL2, matchingDisAlign, matchingDisAlignDynamic] = alignDmw(SkeletonS{i}, SkeletonS{j}, 3, 3, 'Method', 1, 'List',List);
        temporal_score(i,j) = NonLinearityScore(Matching);
        spatial_score(i,j) = SkeletonDistance(SkeletonS{i}, Skeleton2Skeleton(SkeletonS{j}, Matching));
    end
end
spatial_score2 = sum(spatial_score,2);
id_ref = find( spatial_score2 == min(spatial_score2));

%% Align all other frames to this frame in temporal domain
for i=1:nb_SAU
    [Matching, matchingDisL2, matchingDisAlign, matchingDisAlignDynamic] = alignDmw(SkeletonS{id_ref}, SkeletonS{i}, 3, 3, 'Method', 1, 'List',List);
    SkeletonT{i} = Skeleton2Skeleton(SkeletonS{i}, Matching);
end

SkeletonInlier = SkeletonT(spatial_score(id_ref,:)<median(spatial_score(id_ref,:)));
SkeletonR = SpatialSum(SkeletonInlier, 0.1);

%% Write the segmented skeletal sequences
% for i=1:length(SkeletonT)
%     WriteSkeleton(sprintf('Generated Data/0%d_0%d_0%d_0%d_0%d.txt',subject_id,state_id,task_id,rep_id,i), SkeletonT{i}, 'Microsoft Kinect SDK');
% end
% WriteSkeleton(sprintf('Generated Data/0%d_0%d_0%d_0%d_R.txt',subject_id,state_id,task_id,rep_id), SkeletonR, 'Microsoft Kinect SDK');

%% step size
[L, R] = StepSize(SkeletonR);
%% stepping time
T = steppingTime(SkeletonR);
%% postural swing level
PSL = posturalSwingLevel(SkeletonR);
%% left and right hand swing level
[LH, RH] = handSwingLevel(SkeletonR);

%% New Features
NF = new_features(SkeletonR);

%write features to file *Added by Siddhant Kulkarni on September 22, 2015*
filename=strcat('Generated Data/tass-',input_filename);
outputfile=fopen(filename,'w');
stringToWrite=sprintf('%f,%f,%f,%f,%f,%f',L,R,T,PSL,LH,RH);
fprintf(outputfile,stringToWrite);
fclose('all');
