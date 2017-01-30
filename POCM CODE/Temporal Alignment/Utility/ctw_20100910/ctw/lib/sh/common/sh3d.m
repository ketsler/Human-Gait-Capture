function h = sh3d(X, H, varargin)
% Show data as points with different labels for different classes in 3-D figure.
%
% Input
%   X        -  sample matrix, dim x n
%   H        -  indicator matrix, k x n. If empty, H is considered as ones(1, n)
%   varargin
%     proj   -  projection method, {'pca'} | 'lda' | 'qda'
%     itIdx  -  index of interesting points, {[]}
%     mkSiz  -  size of mks, {5}
%     leg    -  legends, {[]}
%     anotI  -  index of point, {[]}
%     anotS  -  string of annotation, {[]}
%     marks  -  mks, {[]}
%     face   -  flag of showing face color, 'y' | {'n'}
%
% Output
%   h        -  figure content handle
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-30-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 06-08-2010

% show option
psSh(varargin);

% function option
proj = ps(varargin, 'proj', 'pca');
mkSiz = ps(varargin, 'mkSiz', 5);
leg = ps(varargin, 'leg', []);
anotI = ps(varargin, 'anotI', []);
anotS = ps(varargin, 'anotS', []);
marks = ps(varargin, 'marks', []);
isFace = psY(varargin, 'face', 'n');
itIdx = ps(varargin, 'itIdx', []);

% dimension
[dim, n] = size(X);
if dim < 3
    error('incorrect dim');
elseif dim > 3
    X = embed(X, H, 3, 'alg', proj);
end

% label
if isempty(H), H = ones(1, n); end
k = size(H, 1); L = G2L(H);

% mks
[mks, cls] = genMkCl;
if k > length(mks)
    error('too much classes');
end
if ~isempty(marks)
    mks = marks;
end

itVis = zeros(1, n);
itVis(itIdx) = 1;

% point
hold on;
poi = cell(1, k);
for c = 1 : k
    Y = X(:, L == c & itVis == 0);
    
    poi{c} = plot3(Y(1, :), Y(2, :), Y(3, :), mks{c}, ...
        'MarkerSize', mkSiz, 'Color', cls{c}, 'LineWidth', 1);

    if isFace
        set(poi{c}, 'MarkerFaceColor', cls{c});
    end
    
    if ~isempty(leg)
        set(poi{c}, 'DisplayName', leg{c});
    end
end
h.poi = poi;

% legend
h.leg = [];
if ~isempty(leg)
    h.leg = legend(leg{:});
end

% interesting points
for i = 1 : length(itIdx)
    idx = itIdx(i);
    c = L(idx);
    
    hi = plot3(X(1, idx), X(2, idx), X(3, idx), mks{c}, ...
        'MarkerSize', mkSiz, 'Color', cls{c}, 'LineWidth', 2, 'MarkerEdgeColor', 'k');
    
    if isFace
        set(hi, 'MarkerFaceColor', 'none');
    else
        set(hi, 'MarkerFaceColor', cls{c});
    end
end

% annotation
nA = length(anotI);
if nA > 0 && isempty(anotS)
    [anotTmp, anotS] = vec2str(1 : nA, '%d');
end

for iA = 1 : nA
    ind = anotI(iA);
%     plot(X(1, ind), X(2, ind), 'o', 'Color', 'k', 'MarkerSize', mkSiz + 2);
    text(X(1, ind), X(2, ind), X(3, ind), anotS{iA});
end

% boundary
setBound(X, 'mar', [.1 .1 .1]);

% angle
view([15 20]);
