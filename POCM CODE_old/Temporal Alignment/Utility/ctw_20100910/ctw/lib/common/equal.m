function flag = equal(s, a, b, varargin)
% Testify whether two objs are equal.
% The obj can be 'numeric', 'cell', 'char' and 'struct'.
%
% Input
%   s       -  name
%   a       -  1st obj
%   b       -  2nd obj
%   varargin
%     prom  -  prompt flag, {'y'} | 'n'
%
% Output
%   flag    -  boolean flag
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-03-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-13-2010

% function option
isProm = psY(varargin, 'prom', 'y');

flag = eqAB(a, b);

if isProm
    if flag
        fprintf('%s equal\n', s);
    else
        fprintf('%s inequal\n', s);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = eqAB(a, b)

% find the type
types = {'numeric', 'cell', 'char', 'struct'};
k = length(types);

for c = 1 : k
    isA = isa(a, types{c});
    isB = isa(b, types{c});
    
    if isA && isB
        break;
    end

    if isA ~= isB
        flag = false;
        return;
    end
end

% numeric matrix
if strcmp(types{c}, 'numeric')
    % dimension
    flag = eqDim(a, b);
    if ~flag
        return;
    end
    
    % infinite value
    a = a(:);
    b = b(:);
    visa = isinf(a);
    visb = isinf(b);
    flag = all(visa == visb);
    if ~flag
        return;
    end
    a = a(~visa);
    b = b(~visb);

    if isempty(a)
        flag = true;
    else
        d = max(abs(a - b));
        flag = d < 1e-10;
    end

% cell
elseif strcmp(types{c}, 'cell')
    % dimension
    flag = eqDim(a, b);
    if ~flag
        return;
    end

    % content
    flag = true;
    for i = 1 : numel(a)
        if ~eqAB(a{i}, b{i})
            flag = false;
            break;
        end
    end

% char
elseif strcmp(types{c}, 'char')
    flag = strcmp(a, b);

% struct array
elseif strcmp(types{c}, 'struct')
    % dimension
    flag = eqDim(a, b);
    if ~flag
        return;
    end
    
    % fieldnames
    nmAs = fieldnames(a);
    nmBs = fieldnames(b);
    flag = length(nmAs) == length(nmBs);
    if ~flag
        return;
    end

    % content
    for j = 1 : length(nmAs)
        nmA = nmAs{j};
        nmB = nmBs{j};
        flag = strcmp(nmA, nmB);
        if ~flag
            return;
        end
    
        for i = 1 : numel(a)
            if ~eqAB(a(i).(nmA), b(i).(nmB))
                flag = false;
                break;
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flag = eqDim(a, b)

siza = size(a);
sizb = size(b);

if length(siza) ~= length(sizb)
    flag = false;
else
    flag = all(siza == sizb);
end
