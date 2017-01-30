function shAli(Xs, P, varargin)
% Show sequences with the alignment.
%
% Input
%   Xs       -  sequence set, 1 x m (cell), dim x ni
%   P        -  alignment path, n x m
%   varargin
%     show option
%     mkSiz  -  marker size, {0}
%     lnWid  -  line width, {1}
%     step   -  step for warping, {0}
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

% dimension
m = length(Xs);
dim = size(Xs{1}, 1);

% embed
if dim == 1
    error('dimension has to be in 2');
    
elseif dim > 2
    Xs = pcaM(X0s, 2);
end

% markers
[mks, cls] = genMkCl;

% sequence
hold on;
for i = 1 : m
    X = Xs{i};
    hTmp = plot(X(1, :), X(2, :), '-', 'Color', cls{i}, 'LineWidth', lnWid);

    if mkSiz
        set(hTmp, 'Marker', mks{i});
        set(hTmp, 'MarkerSize', mkSiz);
        set(hTmp, 'MarkerFaceColor', cls{i});

%         if isMkEg
%             set(hTmp, 'MarkerEdgeColor', 'k');
%         end
    end
end

% boundary
X = cat(2, Xs{:});
setBound(X, 'mar', [.1 .1]);

% alignment
n = size(P, 1);
gap = floor(n * step);
idx = 1 : gap : n;
for p = idx
    i = P(1, p);
    j = P(2, p);

    xi = Xs{1}(:, i);
    xj = Xs{2}(:, j);
    line([xi(1), xj(1)], [xi(2), xj(2)], 'LineStyle', '--', 'Color', 'k', 'LineWidth', lnWid);
end
