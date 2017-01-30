function shM(M, varargin)
% Show matrix in 2-D space.
%
% Input
%   M        -  matrix, n1 x n2
%   varargin
%     show option
%     dis    -  display type, {'imagesc'} | 'contour'
%     clMap  -  color map, {'gray'}
%     bar    -  bar flag, 'y' | {'n'}
%     eq     -  axis equal flag, 'y' | {'n'}
%     seg    -  segmentation, {[]}
%     bdWid  -  line width (for boundary), {1}
%     bdCl   -  line color (for boundary), {[.5 .5 1]}
%     P      -  warping path, {[]}
%     lnWid  -  line width, {1}
%     lnCl   -  line color (for boundary), {'r'}
%     num    -  number flag, 'y' | {'n'}
%     numM   -  number matrix, {M}
%     form   -  number display form, {'%d'}
%     ftSiz  -  font size, {12}
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% show option
psSh(varargin);

% function option
dis = ps(varargin, 'dis', 'imagesc');
clMap = ps(varargin, 'clMap', 'gray');
isBar = psY(varargin, 'bar', 'n');
isEq = psY(varargin, 'eq', 'n');
seg = ps(varargin, 'seg', []);
bdWid = ps(varargin, 'bdWid', 1);
bdCl = ps(varargin, 'bdCl', [.5 .5 1]);
P = ps(varargin, 'P', []);
lnMk = ps(varargin, 'lnMk', '-');
lnWid = ps(varargin, 'lnWid', 1);
lnCl = ps(varargin, 'lnCl', 'r');
isNum = psY(varargin, 'num', 'n');
numM = ps(varargin, 'numM', M);
form = ps(varargin, 'form', '%d');
ftSiz = ps(varargin, 'ftSiz', 12);

% matrix
[n1, n2] = size(M);
if strcmp(dis, 'imagesc')
    imagesc(M);
elseif strcmp(dis, 'contour')
    contour(M);
else
    error(['unknown display type: ' dis]);
end

% color map
if strcmp(clMap, 'gray')
    colormap(gray);
elseif strcmp(clMap, 'hsv')
    colormap(hsv);
else
    error(['unknown color map: ' clMap]);
end

% axis
if isEq
    axis equal;
else
    axis square;
end
axis([1 - .5, n2 + .5, 1 - .5, n1 + .5]);
axis ij;
hold on;
set(gca, 'ticklength', [0 0]);

% color bar
if isBar
    colorbar;
end

% segmentation boundary
if ~isempty(seg) && bdWid > 0
    s = seg.s;
    m = length(s) - 1;
    n = size(M, 1);
    hold on;
    for i = 2 : m
        plot([s(i) s(i)] - .5, [0 n] + .5, '-', 'Color', bdCl, 'LineWidth', bdWid);
        plot([0 n] + .5, [s(i) s(i)] - .5, '-', 'Color', bdCl, 'LineWidth', bdWid); 
    end
end

% warping path
if ~isempty(P)
    plot(P(:, 2), P(:, 1), lnMk, 'Color', lnCl, 'LineWidth', lnWid);
end

% number
if isNum
    [n1, n2] = size(M);
    ma = max(max(M));
    mi = min(min(M));
    colorMap = (M - mi) / (ma - mi);
    for i = 1 : n1
        for j = 1 : n2
            c = colorMap(i, j); p = .7;
            if c < .5
                tColor = [1 1 1] * .95 - p * c;
                if c == 0
                end
            else
                c = 1 - c;
                tColor = [1 1 1] * p * c;
            end

            text(j + 0, i, vec2str(numM(i, j), form), 'HorizontalAlignment', 'center', ...
                'FontSize', ftSiz, 'FontName', 'Time News Roman', 'FontWeight', 'bold', ...
                'Color', tColor);
        end
    end
end
