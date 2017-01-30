function FS = FeetDistance(skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FS = FeetDistance(skeleton)
%% Obtain the height of skeleton head
%%
%% Input:
%% skeleton: A N*M matrix, N is number of frame, M is dimension of each frame
%%
%% Output:
%% FS:        A N*1 vector storing the distance between two feet
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = size(skeleton,1);
d = size(skeleton,2)/3;
F = zeros(n, 1);
for i=1:n
    F(i) = norm( [skeleton(i,12)-skeleton(i,15),...
        skeleton(i,12+d)-skeleton(i,15+d),skeleton(i,12+2*d)-skeleton(i,15+2*d)],2);
end

delta = 1;        %%standard variation for gaussian
kernelG = (1:4*floor(delta)+1);
kernelG = exp(-(kernelG-2*floor(delta)-1).^2/(2*delta^2))/(delta*sqrt(2*pi));
FS = conv(F, kernelG); %%smoothed y value of torso joint
FS = FS(2*floor(delta)+1:length(FS)-2*floor(delta));