function [h, Ys] = shSeq(Xs, varargin)
% Show sequence in 2-D figure.
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
%   Ys       -  new sequence after embedding, 1 x m (cell), dim x ni
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-31-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-02-2010

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

% dimension
m = length(Xs);
dim = size(Xs{1}, 1);
ns = cellDim(Xs, 2);
if dim == 1
    for i = 1 : m
        X0 = Xs{i};
        Xs{i} = [1 : ns(i); X0];
    end
    
elseif dim > 2
    Xs = pcaM(Xs, 2);
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
    
    hTmp = plot(X(1, :), X(2, :));
    
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
            plot(X(1, keyF(j)), X(2, keyF(j)), mks{c}, 'MarkerSize', mkSiz + 7, 'MarkerFaceColor', cls{c}, 'MarkerEdgeColor', 'k');
        end
    end
end

% axis boundary
if isAxis
    if dim > 1, axis equal; end
    
    aspect = ps(varargin, 'aspect', []);
    if isempty(aspect)
        aspect = select(dim == 1, [0.01, 0.1], [0.1, 0.1]);
    end
    X = cat(2, Xs{:});
    lim = setBound(X, 'mar', aspect, 'lim0', lim0);
    
    if nargout > 0
        h.lim = lim;
    end
end

Ys = Xs;
