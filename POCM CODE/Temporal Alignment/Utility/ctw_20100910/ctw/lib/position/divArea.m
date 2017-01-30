function [Areas, meshX, meshY] = divArea(siz, rows, cols)
% Divide the area into blocks.
%
% Input
%   siz     -  size of the whole area
%   rows    -  number of rows
%   cols    -  number of rows
%
% Output
%   Areas   -  the position of areas, 4 x rows x cols
%   meshX   -  x for mesh grid
%   meshY   -  y for mesh grid
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-14-2010

ave = floor(siz ./ [rows, cols]);
Areas = zeros(4, rows, cols);

for r = 1 : rows
    r1 = ave(1) * (r - 1) + 1;
    r2 = ave(1) * r;
    if r == rows, r2 = siz(1); end
    for c = 1 : cols
        c1 = ave(2) * (c - 1) + 1;
        c2 = ave(2) * c;
        if c == cols, c2 = siz(2); end

        Areas(:, r, c) = [r1, c1, r2 - r1 + 1, c2 - c1 + 1]';
    end
end

y = zeros(1, rows);
for r = 1 : rows
    y(r) = Areas(1, r, 1) + floor(Areas(3, r, 1) / 2);
end

x = zeros(1, cols);
for c = 1 : cols
    x(c) = Areas(2, 1, c) + floor(Areas(4, 1, c) / 2);
end

[meshX, meshY] = meshgrid(x, y);
