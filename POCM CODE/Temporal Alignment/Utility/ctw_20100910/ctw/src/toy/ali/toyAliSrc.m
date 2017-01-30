function wsSrc = toyAliSrc(tag, varargin)
% Generate sequence for alignment.
%
% Input
%   tag     -  shape of latent sequence
%              1: sin
%              2: circle
%              3: spiral
%              4: random curve
%   varargin
%     save option
%     t     -  #frame in latent sequence, {200}
%     m     -  #sequence, {2}
%
% Output
%   wsSrc
%     X0    -  latent sequence, 2 x t
%     XTs   -  sequences after temporal transformation, 1 x m (cell)
%     XGs   -  sequences after global spatial transformation, 1 x m (cell)
%     XLs   -  sequences after local  spatial transformation, 1 x m (cell)
%     XGNs  -  sequences after global spatial transformation + noise in 3rd dimension, 1 x m (cell)
%     XLNs  -  sequences after local  spatial transformation + noise in 3rd dimension, 1 x m (cell)
%     aliT  -  ground truth alignment
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-06-2010

% save option
[svL, path] = psSv(varargin, 'subx', 'src', ...
                             'fold', 'toy/ali');

% load
if svL == 2 && exist(path, 'file')
    prom('t', 'old toy ali src: tag %d\n', tag);
    wsSrc = matFld(path, 'wsSrc');
    return;
end
prom('t', 'new toy ali src: tag %d\n', tag);

% function option
t = ps(varargin, 't', 200);
m = ps(varargin, 'm', 2);

% latent sequence
X0 = toyAliSeq(tag, t);

% generate temporal transformation
parTs = tranTemLnPar(t, m);
Qs = cell(1, m);
for i = 1 : m
    Qs{i} = tranTemLn(parTs{i}.n0s, parTs{i}.ns);
end

% ground-truth alignment
P = aliInv(Qs);
aliT = newAli('alg', 'truth', 'P', P);

% generate affine spatial transformation (global)
parSGs = tranSpaAffPar(m);
[PGs, muGs] = cellss(1, m);
for i = 1 : m
    [PGs{i}, muGs{i}] = tranSpaAffG(t, parSGs{i}, [min(X0, [], 2), max(X0, [], 2)]);
end

% apply transformation
[XTs, XSs, Xs, xNs] = cellss(1, m);
for i = 1 : m
    XTs{i} = X0(:, Qs{i});
    XSs{i} = PGs{i} * (X0 + repmat(muGs{i}, 1, t));
    Xs{i} = XSs{i}(:, Qs{i});

    % noise
    xNs{i} = randn(1, size(XSs{i}, 2)) * 5;
end

% xN1 = randn(1, size(XGs{1}, 2)) * 5;
% xN2 = randn(1, size(XGs{2}, 2)) * 5;
% XGNs = {[XGs{1}; xN1], [XGs{2}; xN2]};
% XLNs = {[XLs{1}; xN1], [XLs{2}; xN2]};

% store
wsSrc.X0 = X0;

wsSrc.parTs = parTs;
wsSrc.Qs = Qs;
wsSrc.aliT = aliT;

wsSrc.parSGs = parSGs;
wsSrc.PGs = PGs;
wsSrc.muGs = muGs;

wsSrc.XTs = XTs;
wsSrc.XSs = XSs;
wsSrc.Xs = Xs;
wsSrc.xNs = xNs;

% save
if svL > 0
    save(path, 'wsSrc');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pars = tranTemLnPar(n0, m)
% Generate hyper-parameter for temporal transformation.
%
% Input
%   n0    -  #samples
%   m     -  #sequences
%
% Output
%   pars  -  parameter, 1 x m (cell)

% hyT1.Ran = [.1  .5; ...
%             .3  .6];
% hyT1.lens = [.1 .2];
% hyT1.wins = [.1 .1];
% 
% hyT2.Ran = [.25  .4; ...
%             .3  .6];
% hyT2.lens = [.1 .05];
% hyT2.wins = [.07 .07];

nSeg = 5;
div = 'eq';
ranL = [.3, .9];

pars = cell(1, m);
for i = 1 : m
    % segment position
    n0s = divN(n0, nSeg, 'alg', div);

    % segment length after rescaling
    rates = (rand(nSeg, 1) * (ranL(2) - ranL(1)) + ranL(1));
    ns = round(n0s .* rates);

    pars{i}.n0s = n0s;
    pars{i}.ns = ns;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pars = tranSpaAffPar(m)
% Generate hyper-parameter for spatial transformation (global).
%
% Input
%   m     -  #sequences
%
% Output
%   pars  -  parameter, 1 x m (cell)

par1.bases = {[], [], [], [], []};
par1.Mes   = {[], [], [], [], []};
par1.Vars  = {[], [], [], [], []};
par1.weis  = { 1,  1,  1,  1,  1};

par2.bases = { 0,  1,  1,  0,  0};    
par2.Mes   = {[], [], [], [], []};
par2.Vars  = {[], [], [], [], []};
par2.weis  = { 0,  0,  0,  0,  0};

pars = cell(1, m);
for i = 1 : m
    if mod(i, 2) == 1
        pars{i} = par1;
    else
        pars{i} = par2;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%
function hySLs = genHySL
% Generate hyper-parameter for spatial transformation (local).

hySL1.bases = {      120,                 1,                 1,     0,     0};
hySL1.Mes   = {    [.25],   [.2 .55 .8 .95],    [.25 .5 .6 .8], [.25], [.25]};
hySL1.Vars  = {    [.01], [.01 .01 .01 .01], [.05 .01 .01 .01], [.05], [.05]};
hySL1.weis  = {        1,                 1,                 1,     1,     1};

hySL2.bases = {        0,         1,         1,        [],        []};
hySL2.Mes   = {[.25 .4 ], [.25 .7 ], [.25 .7 ], [.25 .6 ], [.25 .6 ]};
hySL2.Vars  = {[.05 .01], [.05 .05], [.05 .05], [.05 .05], [.05 .05]};
hySL2.weis  = {        1,         1,         1,         1,         1};

hySLs = {hySL1, hySL2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hySG1, hySG2, hySL1, hySL2] = genTranS2
% Generate hyper-parameter for spatial transformation.

Para = [nan,   0,  10; ...
        nan,   1,   1; ...
        nan,  .2,   1; ...
          0,   0,   0; ...
          0,   0,   0];
mes  = [  0,   0,   0];
vars = [inf, inf, inf];
weis = [  1,   1,   1];

idx = 1;
hySG1.Para = Para(:, idx);
hySG1.mes  = mes(idx);
hySG1.vars = vars(idx);
hySG1.weis = weis(idx);

idx = [];
hySG2.Para = Para(:, idx);
hySG2.mes  = mes(idx);
hySG2.vars = vars(idx);
hySG2.weis = weis(idx);
