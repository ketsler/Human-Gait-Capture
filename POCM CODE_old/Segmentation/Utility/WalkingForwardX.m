function V = WalkingForwardX(skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% V = WalkingForwardX(skeleton)
%% Obtain the validity mask of each skeleton
%%
%% Input:
%% skeleton: A N*M matrix, N is number of frame, M is dimension of each frame
%%
%% Output:
%% V:        A N*1 vector with 1 stands for valid skeleton and 0 otherwise
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = size(skeleton,1);            %%nb of frames
d = size(skeleton,2)/3;          %%nb of joints
V = zeros(n, 1);                 %%initialization
delay = 2;                       %%delay step
delta = 25;                      %%standard variation for gaussian
TorsoX = skeleton(:,1);          %%x value of torso joint

kernelG = (1:4*floor(delta)+1);
kernelG = exp(-(kernelG-2*floor(delta)-1).^2/(2*delta^2))/(delta*sqrt(2*pi));
TorsoXS = conv(TorsoX, kernelG); %%smoothed y value of torso joint
TorsoXS = TorsoXS(2*floor(delta)+1:length(TorsoXS)-2*floor(delta));

for i=delay+1:n
    if( TorsoXS(i) > TorsoXS(i-delay) )
        V(i) = 1;
    end
end