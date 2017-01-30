function X = areaAve(X0, rows, cols)
% Obtain the average value in each block.
%
% Input
%   X0      -  old matrix, h0 x w0
%   rows    -  #rows
%   cols    -  #columns
%
% Output
%   X       -  new matrix, rows x cols
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 03-14-2010

% area's position
siz = size(X0);
Areas = divArea(siz, rows, cols);

% area by area
X = zeros(rows, cols);
for r = 1 : rows
    for c = 1 : cols
        
        r1 = Areas(1, r, c);
        c1 = Areas(2, r, c);
        r2 = Areas(3, r, c) + r1 - 1;
        c2 = Areas(4, r, c) + c1 - 1;
        
        area = X0(r1 : r2, c1 : c2);
        X(r, c) = mean(area(:));
    end
end
