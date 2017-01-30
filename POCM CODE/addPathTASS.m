% Author: Ruizhe Wang
% Date: May 2013
% Paper: Home Monitoring Musculo-Skeletal Disorders with a 3D Sensor, CVPRW
% 2013, Ruizhe Wang, Gerard Medioni, Carolee J. Winstein and Cesar Blanco
%
% ------------------
% Function: add path for the Temporal Alignment Spatial Summarization
% (TASS) toolbox

function addPathTASS
% Add folders of predefined functions into matlab searching paths.

global footpath;

footpath = cd;
cd(footpath);
addpath(genpath([footpath '/Skeletal Data']));
addpath(genpath([footpath '/Input & Output']));
addpath(genpath([footpath '/Interface']));
addpath(genpath([footpath '/Miscellaneous']));
addpath(genpath([footpath '/Segmentation']));
addpath(genpath([footpath '/Segmentation/Utility']));
addpath(genpath([footpath '/Spatial Alignment']));
addpath(genpath([footpath '/Spatial Summarization']));
addpath(genpath([footpath '/Temporal Alignment']));
addpath(genpath([footpath '/Extract Parameters']));
addpath(genpath([footpath '/Temporal Alignment/utility']));
addpath(genpath([footpath '/Temporal Alignment/utility/ctw_20100910/ctw']));
addpath(genpath([footpath '/Generated Data']));
