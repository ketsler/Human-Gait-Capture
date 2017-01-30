function h = sh(X, varargin)
% Show points in 2-D.
%
% Input
%   X        -  sample matrix, dim x n
%   varargin
%     show option
%     G      -  class indicator matrix, {[]} | k x n
%     mkSiz  -  size of markers, {5} | 1 x 1
%     leg    -  legends, {[]} | 1 x m (cell)
%     anotI  -  index of point, {[]}
%     anotS  -  string of annotation, {[]}
%     face   -  flag of showing face color, 'y' | {'n'}
%
% Output
%   h        -  figure handle
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-30-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 08-01-2010

% show option
psSh(varargin);

% function option
G = ps(varargin, 'G', []);
mkSiz = ps(varargin, 'mkSiz', 5);
leg = ps(varargin, 'leg', []);
anotI = ps(varargin, 'anotI', []);
anotS = ps(varargin, 'anotS', []);
isFace = psY(varargin, 'face', 'n');

% embed
[dim, n] = size(X);
if dim == 1
    X = [1 : n; X];
    
elseif dim > 2
    X = pca(X, 2);
end

% label
if isempty(G)
    G = ones(1, n); 
end
k = size(G, 1); l = G2L(G);

% plot
hold on;
h.clu = cell(1, k);
for c = 1 : k
    Y = X(:, l == c);
    
    [mk, cl] = genMkCl(c);

    h.clu{c} = plot(Y(1, :), Y(2, :), mk, ...
        'MarkerSize', mkSiz, 'Color', cl);

    if isFace
        set(h.clu{c}, 'MarkerFaceColor', cl)
    end

    if ~isempty(leg)
        set(h.clu{c}, 'DisplayName', leg{c});
    end
end

% legend
if ~isempty(leg)
    legend('toggle');
end

% annotation
nA = length(anotI);
if nA > 0 && isempty(anotS)
    [anotTmp, anotS] = vec2str(1 : nA, '%d');
end

for iA = 1 : nA
    ind = anotI(iA);
%     plot(X(1, ind), X(2, ind), 'o', 'Color', 'k', 'MarkerSize', mkSiz + 2);
    text(X(1, ind), X(2, ind), anotS{iA});
end

% boundary
setBound(X, 'mar', [.1 .1]);

axis equal;
% point position in axes
poss = zeros(2, n);
pos0 = get(gca, 'Position');
xlim = get(gca, 'Xlim');
ylim = get(gca, 'Ylim');
for i = 1 : n
    poss(1, i) = pos0(1) + pos0(3) * (X(1, i) - xlim(1)) / (xlim(2) - xlim(1));
    poss(2, i) = pos0(2) + pos0(4) * (X(2, i) - ylim(1)) / (ylim(2) - ylim(1));
end
h.poss = poss;
