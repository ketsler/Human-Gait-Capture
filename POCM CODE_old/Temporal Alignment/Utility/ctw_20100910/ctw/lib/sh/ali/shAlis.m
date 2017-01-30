function shAlis(alis, varargin)
% Show alignment in 2-D figure.
%
% Input
%   alis    -  alignment set, 1 x m (cell)
%   varargin
%     show option
%     algs  -  algorithm name (used for legend), {[]}
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-06-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% show option
psSh(varargin);

% function option
algs = ps(varargin, 'algs', []);

if ~iscell(alis)
    alis = {alis};
end
m = length(alis);

% markers
markers = {'-', '--', ':', '-.', '-', '-'};
% color2s = {'k', [.8 .3 .3], [.3 .3 .8], 'g', [.2 .2 .2], [.1 .1 .1]};
colors = {'k', 'r', 'b', 'g', 'm', 'c'};
lnWids =  [  2,   2,   2,    2,   2,   2];

% markers = {'-', '-', '-', '--', ':', '-.'};
% colors =  {'k', [.8 .3 .3], [.3 .3 .8], 'g', 'b', 'r'};
% lnWids =  [  3,   2,   1,    2,   2,   2];

hold on;
for i = 1 : m
    P = alis{i}.P;
    
    if i <= 10
        plot(P(:, 2), P(:, 1), markers{i}, 'Color', colors{i}, 'LineWidth', lnWids(i));
    else
        plot(P(:, 2), P(:, 1), '-', 'Color', colors{i}, 'LineWidth', 2);
        idx = linspace(1, size(P, 1), 10);
        idx = round(idx);
        plot(P(idx, 2), P(idx, 1), markers{i}, 'MarkerSize', 7, 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', colors{i});
    end
end
axis ij;

% boundary
n1 = alis{1}.P(end, 1);
n2 = alis{1}.P(end, 2);
axis([1, n2, 1, n1]);

if ~isempty(algs)
    legend(algs{:});
end
