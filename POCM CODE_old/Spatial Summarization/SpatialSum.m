function data = SpatialSum(raw_data, lambda)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% data = TemporalSmoothing(raw_data, lambda)
%%
%% Input:
%% raw_data: a cell containing the raw datas
%% lambda:   smooth term weight
%% 
%% Output:
%% data:     temporal smoothed data that fit the model
%%
%% Note:
%% data is a (N, M) matrix, and each data of raw_data is
%% also a (N, M) matrix, where N is the total number of frame 
%% and M is the dimensionality of each frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 0: Basic information
number_data = length(raw_data);
if( number_data < 1)
    msgbox('We do not have raw data!!!!');
end
N = size(raw_data{1},1);
M = size(raw_data{1},2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 1: Data term matrix
%% Ax = B
A = sparse(1:N*M, 1:N*M, number_data);
B = sparse(N*M, 1);
for i=1:number_data
    temp = raw_data{i}';
    temp = temp(:); %matrix to vector
    B = B + sparse(temp); %matrix to sparse matrix
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 2: Temporal constraint term
%% fixed matrix
kernel = [lambda*eye(M),-lambda*eye(M)];
for i=1:N-1
    C = zeros(M, N*M);
    C(:,(i-1)*M+1:(i+1)*M) = kernel;
    C = sparse(C);
    A = A + C'*C;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Step 3: Solve the linear system
X = A\B;
X = full(X); %sparse matrix to full matrix
data = reshape(X, M, N); %vector to matrix
data = data';

