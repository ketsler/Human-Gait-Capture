function box = setBound(X, varargin)
% Set the boundary of the figure.
%
% Input
%   X       -  sample matrix, dim x n
%   varargin
%     mar   -  marginal aspect, {.1}
%     siz0  -  bounding box size, {[]}
%     w2h0  -  aspect ratio height with respect to width, {[]}
%     h2w0  -  aspect ratio width with respect to height, {[]}
%     box0  -  bounding box position, {[]}
%     set   -  setting flag, {'y'} | 'n'
%              If 'n', only compute the bounding box and not adjust the axis
%
% Output
%   box     -  bounding box, dim x 2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-29-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-31-2010

% function option
mar = ps(varargin, 'mar', .1);
siz = ps(varargin, 'siz0', []);
w2h = ps(varargin, 'w2h0', []);
h2w = ps(varargin, 'h2w0', []);
box0 = ps(varargin, 'box0', []);
isSet = psY(varargin, 'set', 'y');

% dimension
dim = size(X, 1);

% bounding box size
if ~isempty(siz)
    center = mean(X, 2);
    if length(siz) == 1
        siz = ones(dim, 1) * siz;
    else
        siz = siz(:);
    end
    box = [center - siz / 2, center + siz / 2];

% bounding box position
elseif ~isempty(box0)
    box = box0;

% bounding box position
elseif ~isempty(w2h)
    center = mean(X, 2);
    mi = min(X, [], 2);
    ma = max(X, [], 2);
    siz = ma - mi;
    
    if length(mar) == 1
        mar = ones(dim, 1) * mar;
    else
        mar = mar(:);
    end
    
    siz = siz .* (1 + mar);
    siz2 = siz / 2;
    siz2(2) = w2h * siz2(1);

    box = [center - siz2, center + siz2];

elseif ~isempty(h2w)
    center = mean(X, 2);
    mi = min(X, [], 2);
    ma = max(X, [], 2);
    siz = ma - mi;
    
    if length(mar) == 1
        mar = ones(dim, 1) * mar;
    else
        mar = mar(:);
    end
    
    siz = siz .* (1 + mar);
    siz2 = siz / 2;
    siz2(1) = h2w * siz2(2);

    box = [center - siz2, center + siz2];

else
    mi = min(X, [], 2);
    ma = max(X, [], 2);
    siz = ma - mi;
    siz(siz == 0) = .1;
    
    if length(mar) == 1
        mar = ones(dim, 1) * mar;
    else
        mar = mar(:);
    end
    
    box = [mi - siz .* mar, ma + siz .* mar];
end

% adjust
if isSet
    if abs(box(1, 1) - box(1, 2)) > eps
        xlim([box(1, 1), box(1, 2)]);
    end
    
    if abs(box(2, 1) - box(2, 2)) > eps
        ylim([box(2, 1), box(2, 2)]);
    end
    
    if size(box, 1) > 2
        zlim([box(3, 1), box(3, 2)]);
    end
end
