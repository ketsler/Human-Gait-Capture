function V = WalkingBackwardY(skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% V = WalkingForward(skeleton)
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
delay = 2;                      %%delay step
delta = 25;                      %%standard variation for gaussian
TorsoY = skeleton(:,1+d);        %%y value of torso joint

kernelG = (1:4*floor(delta)+1);
kernelG = exp(-(kernelG-2*floor(delta)-1).^2/(2*delta^2))/(delta*sqrt(2*pi));
TorsoYS = conv(TorsoY, kernelG); %%smoothed y value of torso joint
TorsoYS = TorsoYS(2*floor(delta)+1:length(TorsoYS)-2*floor(delta));

for i=delay+1:n
    if( TorsoYS(i) < TorsoYS(i-delay) )
        V(i) = 1;
    end
end