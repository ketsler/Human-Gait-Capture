function X = toyAliSeq(shp, n)
% Generate 2-D latent sequence.
%
% Input
%   shp     -  sequence shape
%              1: sin
%              2: circle
%              3: spiral
%              4: random curve
%   n       -  #frames
%
% Output
%   X       -  sequence, 2 x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 03-17-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% sin
if shp == 1
    x = linspace(0, 10, n);
    y = sin(x);

% circle
elseif shp == 2
    ang = linspace(0, 2 * pi, n);
    x = cos(ang);
    y = sin(ang);

% spiral
elseif shp == 3
% old
%     t = 4 * pi * (1 : n) / n;
%     t = 4 * pi * (1 : n) / n;
%     a = ((1 : n) - 1) / (n - 1) * (exp(1) - 1) + 1;
%     b = log(a) * (n - 1) + 1;

    a = ((1 : n) - 1) / (n - 1);
    b = a .^ (1 / 2) * (n - 1) + 1;
    t = 4 * pi * b / n;

    x = t .* cos(t);
    y = t .* sin(t);

% random curve
elseif shp == 4
    wei = select(iTag == 4, .9, .1);
    DX = randn(2, n);

    X = zeros(2, n);
    dx0 = [0; 0];
    for i = 2 : n
        X(:, i) = X(:, i - 1) + dx0 * wei + (1 - wei) * DX(:, i);
        dx0 = X(:, i) - X(:, i - 1);
    end
    x = X(1, :);
    y = X(2, :);

else
    error('unknown shape');
end

X = [x; y];
