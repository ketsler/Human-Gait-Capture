function MergeFiles( fileList, fileName, shift3D)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MergeFiles( fileList, shift3D)
%% Usage
%% fileList: List of skeleton files to be merged
%% fileName: The name of the final file
%% shift3D: num vector, translation between two consecutive frames
%% e.g. [1000,0,0]
nb_file = length(fileList);
fids = zeros(nb_file, 1);
lengths = zeros(nb_file, 1);
global software;
global dimension;
% preprocess to get the number of frames for each file
for i=1:nb_file
    file_path = fileList{i};
    fids(i) = fopen(file_path, 'r'); %open file
    software = fgetl(fids(i)); %software platform
    lengths(i) = str2double( fgetl(fids(i))); %nb of frames
    dimension = str2double( fgetl(fids(i))); %dimensionality
end
% now start to write into our file
length_all = max(lengths);
fid_all = fopen(fileName, 'w');
fprintf(fid_all, '%s\n%d\n%d\n', software, length_all, dimension);
for i=1:length_all
    fprintf(fid_all, '%d\n', i); % write frame index
    count_skeleton = zeros(nb_file,1); % nb of skeleton per frames all together
    % count nb of skeletons all together
    for j=1:nb_file
        if( i <= lengths(j))
            fgetl(fids(j));
            count = str2double(fgetl(fids(j)));
            if( count == -1 )
                count = 0;
            end
            count_skeleton(j) = count;
        end
    end
    fprintf(fid_all, '%d\n', sum(count_skeleton)); % write total number of skeleton
    % write skeleton information
    for j=1:nb_file
        if( i <= lengths(j))
            for k=1:count_skeleton(j)
                temp = fscanf(fids(j),'%f\n',[3 dimension]);  %read the data for each use
                for l=1:dimension
                    fprintf(fid_all, '%f %f %f\n', temp(1,l)+shift3D(1)*(j-1),...
                        temp(2,l)+shift3D(2)*(j-1), temp(3,l)+shift3D(3)*(j-1));
                end
            end
        end
    end
end
% now close all files
for i=1:nb_file
    fclose(fids(i));
end
fclose(fid_all);
