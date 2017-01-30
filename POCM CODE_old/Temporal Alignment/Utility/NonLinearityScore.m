function Score = NonLinearityScore(AlignmentPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Score = NonLinearityScore(AlignmentPath)
%% Input:
%% AlignmentPath: An AlignmentPath we obtain from the DMW
%% Output:
%% Score:         The score indicating the nonlinearity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Obtain L_x and L_y
L_x = AlignmentPath(length(AlignmentPath));
L_y = length(AlignmentPath);
%% Step 2: Calculate the score
I = (1:L_y) - 1;
Q = AlignmentPath - 1;
Score = sum(abs((L_x-1)*I-(L_y-1)*Q))/(L_y*((L_x-1)^2+(L_y-1)^2));