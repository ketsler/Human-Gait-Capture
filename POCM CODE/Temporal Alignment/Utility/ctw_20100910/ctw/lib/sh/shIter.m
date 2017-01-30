function shIter(costs, iters, varargin)
% Show cost at each iterations.
%
% Input
%   costs    -  costs, 1 x co
%   iters    -  iteration ids, 1 x co
%   varargin
%     show option
%     axis   -  axis flag, {'y'} | 'n'
%     lnWid  -  line width, {1}
%     mkSiz  -  size of mks, {0}
%     mkEg   -  flag of marker edge, {'y'} | 'n'
%     lim0   -  predefined limitation, {[]}
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 09-20-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 09-06-2010

% show option
psSh(varargin);

% function option
lnCl = ps(varargin, 'lnCl', 'r');
lnWid = ps(varargin, 'lnWid', 1);
mkSiz = ps(varargin, 'mkSiz', 0);
isMkEg = psY(varargin, 'mkEg', 'y');

hold on;

% iterations
[mks, cls] = genMkCl;
if isempty(iters)
    iters = ones(1, length(costs));
end

k = max(iters);
[as, hIters] = cellss(1, k);
vis = ones(1, k);
for c = 1 : k
    pos = find(iters == c);

    if isempty(pos)
        vis(c) = 0;
        continue;
    end

    as{c} = it2a(c);
    hIters{c} = plot(pos, costs(pos), mks{c}, 'Color', cls{c});

    if mkSiz > 0
        set(hIters{c}, 'Marker', mks{c}, 'MarkerSize', mkSiz, 'MarkerFaceColor', cls{c});

        if isMkEg
            set(hIters{c}, 'MarkerEdgeColor', 'k');
        end
    end
end
as(vis == 0) = [];

if k > 1
    legend(as);
end

% costs
co = length(costs);
plot(costs, '-', 'LineWidth', lnWid, 'Color', lnCl);


