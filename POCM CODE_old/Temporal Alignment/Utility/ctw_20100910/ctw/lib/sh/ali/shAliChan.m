function [h, Ys, Zs] = shAliChan(Xs, ali, varargin)
% Show each channel of the given sequence.
%
% Input
%   Xs        -  set of sequence, 1 x m (cell), dim x ni
%   ali       -  alignment
%     P       -  alignment path, n x m
%   varargin
%     show option
%     idxD    -  index of dimension, {[]}
%     gap     -  gap between two channels, {.5}
%     lnWid   -  line width, {1}
%     mkSiz   -  size of markers, {5}
%     mkEg    -  flag of marker edge, {'y'} | 'n'
%     nms     -  channel names, {[]}
%
% Output
%   h         -  handle for the figure
%     lim     -  limitation of the axis
%   Ys        -  new sequence (after adjusting the range), 1 x k (cell), dim x ni
%   Zs        -  new sequence (after adjusting the range and plotting on the figure), 1 x k (cell), dim x ni
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 03-31-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 09-06-2010

% show option
psSh(varargin);

% function option
idxD = ps(varargin, 'idxD', []);
gap = ps(varargin, 'gap', .5);
lnWid = ps(varargin, 'lnWid', 1);
mkSiz = ps(varargin, 'mkSiz', 5);
isMkEg = psY(varargin, 'mkEg', 'y');
nms = ps(varargin, 'nms', []);

% dimension
m = length(Xs);
dim = size(Xs{1}, 1);
ns = cellDim(Xs, 2);

if ~isempty(idxD)
    for j = 1 : m
        Xs{j} = Xs{j}(idxD, :);
    end
    dim = length(idxD);
end

% alignment
[idxXs, idxYs] = cellss(1, m);
P = ps(ali, 'P', []);
if isempty(P)
    for j = 1 : m
        idxXs{j} = 1 : ns(j);
        idxYs{j} = 1 : ns(j);
    end
else
    for j = 1 : m
        idxXs{j} = 1 : size(P, 1);
        idxYs{j} = P(:, j);
    end
end

% chan
[Ys, Zs] = cellss(1, m);
for j = 1 : m
    [Ys{j}, Zs{j}] = zeross(dim, ns(j));
end
[mis, mas] = zeross(1, dim);
tiPs = cellss(1, dim);

% markers
[mks, cls] = genMkCl;
hold on;

% each channel
base = 0;
for d = 1 : dim
    mid = inf;
    mad = -inf;
    for j = 1 : m
        mid = min(min(Xs{j}(d, :)), mid);
        mad = max(max(Xs{j}(d, :)), mad);
    end

    for j = 1 : m
        x = Xs{j}(d, :);
        mis(d) = base;
        mas(d) = base + 1;
%         mid = min(x); 
%         mad = max(x); 

        y = (x - mid) / (mad - mid);
        Ys{j}(d, :) = y;

        z = y + base;
        Zs{j}(d, :) = z;

        % plot
        hTmp = plot(idxXs{j}, z(idxYs{j}), '-', 'LineWidth', lnWid);

        % color
        set(hTmp, 'Color', cls{j});

        % marker
        if mkSiz > 0
            set(hTmp, 'Marker', mks{j}, 'MarkerSize', mkSiz, 'MarkerFaceColor', cls{j});

            if isMkEg
                set(hTmp, 'MarkerEdgeColor', 'k');
            end
        end
    end

    % ticks
    tiPs{d} = base + .5;

    % base
    base = base + 1 + gap;
end

% ticks
set(gca, 'ticklength', [0 0]);
set(gca, 'YTick', cat(2, tiPs{:}), 'YTickLabel', nms);

mi = 0;
ma = base - gap;

% boundary
if isempty(P)
    axis([1, max(ns), mi, ma]);

    % handle
    h.lim = [1, max(ns); ...
             mi, ma];
else
    axis([1, size(P, 1), mi, ma]);

    % handle
    h.lim = [1, size(P, 1); ...
             mi, ma];
end
