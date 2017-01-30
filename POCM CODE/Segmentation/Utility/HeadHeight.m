function hS = HeadHeight(skeleton)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% h = HeadHeight( skeleton )
%% Obtain the height of skeleton head
%%
%% Input:
%% skeleton: A N*M matrix, N is number of frame, M is dimension of each frame
%%
%% Output:
%% h:        A N*1 vector
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = skeleton(:,3); %% z value of first joint (head)

delta = 20;        %%standard variation for gaussian

kernelG = (1:4*floor(delta)+1);
kernelG = exp(-(kernelG-2*floor(delta)-1).^2/(2*delta^2))/(delta*sqrt(2*pi));
hS = conv(h, kernelG); %%smoothed y value of torso joint
hS = hS(2*floor(delta)+1:length(hS)-2*floor(delta));