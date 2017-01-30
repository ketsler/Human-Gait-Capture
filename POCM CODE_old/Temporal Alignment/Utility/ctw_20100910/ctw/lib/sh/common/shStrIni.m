function h = shStrIni(str, varargin)
% Show a string list (Initialization).
%
% Input
%   strs     -  string
%   varargin
%     show option
%     ti     -  title, {[]}
%     cl     -  string color, {[.4 .4 .4]}
%     ftNme  -  font name, {'Arial'}
%     ftSiz  -  font size, {23}
%
% Output
%   h        -  handle container
%     hStrs  -  string handle
%     vis    -  visit flag, 1 x n
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-31-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 08-16-2010

% show option
psSh(varargin);

% function option
cl = ps(varargin, 'cl', [.4 .4 .4]);
ftNme = ps(varargin, 'ftNme', 'Monoca');
ftSiz = ps(varargin, 'ftSiz', 23);

h.hStr = text('Position', [.5, .5], 'HorizontalAlignment', 'center', 'Units', 'Normalized', ...
    'String', str, 'Color', cl, 'LineWidth', 1, ...
    'FontName', ftNme, 'FontSize', ftSiz, 'FontWeight', 'bold');
