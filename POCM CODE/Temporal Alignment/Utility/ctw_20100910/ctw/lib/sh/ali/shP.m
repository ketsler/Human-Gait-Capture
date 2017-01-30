function shP(P, varargin)
% Show path matrix of alignment.
%
% Input
%   P       -  warping path vectors, n x m
%   varargin
%     show option
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 05-08-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% show option
psSh(varargin);

% dimension
[n, m] = size(P);

% marker & color
[mks, cls] = genMkCl;

hold on;
for i = 1 : m
    plot(1 : n, P(:, i)', '-', 'Color', cls{i}, 'LineWidth', 2);
end
axis equal;

% axis([1, n, 1, ni]);
%     set(gca, 'XTick', [1, n0], 'XTickLabel', {'0', '1'}, 'YTick', [1, n], 'YTickLabel', {'0', '1'});
% set(gca, 'XTickLabel', {}, 'YTickLabel', {}, 'ticklength', [0 0]);