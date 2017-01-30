function [h, Ys] = shSeq3d(Xs, varargin)
% Show sequence in 3-D figure.
%
% Input
%   Xs       -  sequence set, 1 x m (cell), dim x ni
%   varargin
%     show option
%     axis   -  axis flag, {'y'} | 'n'
%     lnWid  -  line width, {1}
%     mkSiz  -  size of mks, {0}
%     mkEg   -  flag of marker edge, {'y'} | 'n'
%     lim0   -  predefined limitation, {[]} 
%
% Output
%   h        -  handle for the figure
%     lim    -  limitation of the axis
%   Ys       -  new sequence after projection, 1 x m (cell), 2 x ni
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-31-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% show option
psSh(varargin);

% function option
isAxis = psY(varargin, 'axis', 'y');
lnWid = ps(varargin, 'lnWid', 1);
mkSiz = ps(varargin, 'mkSiz', 0);
isMkEg = psY(varargin, 'mkEg', 'y');
lim0 = ps(varargin, 'lim0', []);
keyFs = ps(varargin, 'keyFs', {});

if ~iscell(Xs)
    Xs = {Xs};
end

% dimensionality of sample
m = length(Xs);
dim = size(Xs{1}, 1);
ns = cellDim(Xs, 2);
if dim < 3
    error('The dimension has to be bigger than 3.');
    
elseif dim > 3
    X0 = cat(2, Xs{:});
    s = n2s(ns);
    X = embed(X0, [], 3, 'alg', 'pca');
    for i = 1 : m
        Xs{i} = X(:, s(i) : s(i + 1) - 1);
    end
end

% mks
[mks, cls] = genMkCl;
if m > length(mks)
    error('too much classes');
end

% main display
hold on;
for i = 1 : m
    X = Xs{i};
    c = i;
    
    hTmp = plot3(X(1, :), X(2, :), X(3, :));
    
    % line
    if lnWid > 0
        set(hTmp, 'LineStyle', '-', 'LineWidth', lnWid, 'Color', cls{c});
    else
        set(hTmp, 'LineStyle', 'none');
    end

    % marker
    if mkSiz > 0
        set(hTmp, 'Marker', mks{c}, 'MarkerSize', mkSiz, 'MarkerFaceColor', cls{c});

        if isMkEg
            set(hTmp, 'MarkerEdgeColor', 'k');
        end
    end
    
    % keyframe
    if ~isempty(keyFs)
        keyF = keyFs{c};
        for j = 1 : length(keyF)
            plot3(X(1, keyF(j)), X(2, keyF(j)), mks{c}, 'MarkerSize', mkSiz + 7, 'MarkerFaceColor', cls{c}, 'MarkerEdgeColor', 'k');
        end
    end
end

% axis boundary
if isAxis
    if dim > 1, axis equal; end
    
    aspect = ps(varargin, 'aspect', [.1 .1 .1]);
    X = cat(2, Xs{:});
    lim = setBound(X, 'mar', aspect, 'lim0', lim0);
    
    if nargout > 0
        h.lim = lim;
    end
end

Ys = Xs;
