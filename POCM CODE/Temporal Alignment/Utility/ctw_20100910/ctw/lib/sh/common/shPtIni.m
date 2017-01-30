function h = shPtIni(x, varargin)
% Show one point in the 2-D figure.
%
% Input
%   x        -  point position, 1 x 2
%   varargin
%     show option
%     mkCl   -  marker color, {'y'}
%     mkSiz  -  size of markers, {5}
%     mkEg   -  flag of marker edge, {'y'} | 'n'
%
% Output
%   h        -  figure content handle
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 02-03-2010
%   modify   -  Feng Zhou (zhfe99@gmail.com), 08-16-2010

% show option
psSh(varargin);

% function option
mkCl = ps(varargin, 'mkCl', 'y');
mkSiz = ps(varargin, 'mkSiz', 6);
isMkEg = psY(varargin, 'mkEg', 'y');

h = plot(x(1), x(2), 'o', 'MarkerSize', mkSiz, 'MarkerFaceColor', mkCl);

if isMkEg
    set(h, 'MarkerEdgeColor', 'k');
end
