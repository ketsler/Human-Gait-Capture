function P = aliInv(Qs)
% Obtain the ground truth alignment.
%
% Input
%   Qs      -  original warping path vector, 1 x m (cell), ni x 1
%
% Output
%   P       -  new warping path, t x m
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 09-13-2010
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

% dimension
m = length(Qs);
ns = cellDim(Qs, 1);

t = Qs{1}(end);
for i = 2 : m
    if t ~= Qs{i}(end)
        error('Number t must be the same');
    end
end

P = zeros(t, m);
for j = 1 : m
    q = Qs{j};
    n = ns(j);

    P(1, j) = 1;
    P(q, j) = 1 : n;
    
    vis = real(P(:, j) ~= 0);
    
    head = vis(2 : end) - vis(1 : end - 1);
    head = find(head < 0) + 1;

    tail = vis(2 : end) - vis(1 : end - 1);
    tail = find(tail > 0);
    
    for ii = 1 : length(head)
        h = head(ii) - 1;
        t = tail(ii) + 1;
        P(h : t, j) = round(linspace(P(h, j), P(t, j), t - h + 1));
    end
end
