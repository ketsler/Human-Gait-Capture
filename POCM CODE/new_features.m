function Features = new_features(Skeleton)
    Features = [];

    for a=1:size(Skeleton,1)
        X = Skeleton(a,1:15);
        Y = Skeleton(a,16:30);
        Z = Skeleton(a,31:45);
        
        %% Get the distance between each pair of joints
        for i=1:15
            for j=i:15
                Tmp = ((X(i) - X(j))^2 + (Y(i) - Y(j))^2 + (Z(i) - Z(j))^2)^0.5;
                distance_matrix(i,j) = Tmp;
            end
        end
        
        all_data{a} = distance_matrix;       
    end
    
    for b=1:size(Skeleton,2)/3
        Features = [Features std(std(all_data{:,b}))];
    end 
end
