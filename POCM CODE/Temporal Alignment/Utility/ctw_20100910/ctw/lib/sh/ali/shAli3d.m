function shAli3d(Xs, C, varargin)
% Show sequences with the correspondances on their frames.
%
% Input
%   Xs       -  sequence set, 1 x m (cell), dim x ni
%   C        -  correspondence matrix, 2 x m
%   varargin
%     show option
%     mkSiz  -  marker size, {0}
%     lnWid  -  line width, {1}
%     step   -  step for warping, {0}
%     cs     -  
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-03-2010

% show option
psSh(varargin);

% function option
mkSiz = ps(varargin, 'mkSiz', 0);
lnWid = ps(varargin, 'lnWid', 1);
step = ps(varargin, 'step', 0);
cs = ps(varargin, 'cs', [1 2]);

% dimensionality of sample
m = length(Xs);
dim = size(Xs{1}, 1);
ns = cellDim(Xs, 2);
if dim == 1
    error('use showSeqAli1d instead');
    
elseif dim > 3
    X0 = cat(2, Xs{:});
    s = n2s(ns);
    X = embed(X0, [], 3, 'alg', 'pca');
    for i = 1 : m
        Xs{i} = X(:, s(i) : s(i + 1) - 1);
    end
end

% markers
[markers, colors] = genMkCl;

% sequence
hold on;
for i = 1 : m
    X = Xs{i};
    c = cs(i);
    
    hTmp = plot3(X(1, :), X(2, :), X(3, :), '-', 'Color', colors{c}, 'LineWidth', lnWid);

    if mkSiz
        set(hTmp, 'Marker', markers{c});
        set(hTmp, 'MarkerSize', mkSiz);
        set(hTmp, 'MarkerFaceColor', colors{c});

%         if isMkEg
%             set(hTmp, 'MarkerEdgeColor', 'k');
%         end
    end
end

% boundary
X = cat(2, Xs{:});
setBound(X, 'mar', [.1 .1 .1]);

% warping
m = size(C, 2);
gap = floor(m * step);
idx = 1 : gap : m;
for p = idx
    i = C(1, p);
    j = C(2, p);

    xi = Xs{1}(:, i);
    xj = Xs{2}(:, j);
    line([xi(1), xj(1)], [xi(2), xj(2)], 'LineStyle', '--', 'Color', 'k', 'LineWidth', lnWid);
end
