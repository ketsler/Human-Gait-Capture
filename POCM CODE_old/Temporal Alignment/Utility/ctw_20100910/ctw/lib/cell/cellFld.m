function varargout = cellFld(A, varargin)
% Obtain field of each cell element.
%
% Input
%   A          -  struct cell array, n1 x n2 x n3 x ... (cell)
%   varargin   -  field name list, 1 x m (cell)
%
% Output
%   varargout  -  field value list, 1 x m
%
% History
%   create     -  Feng Zhou (zhfe99@gmail.com), 02-01-2009
%   modify     -  Feng Zhou (zhfe99@gmail.com), 06-06-2010

% dimension
ndim = ndims(A);
dims = cell(1, ndim);
n = numel(A);
for i = 1 : ndim
    dims{i} = size(A, i);
end

m = length(varargin);

if nargout ~= m
    error('The number of outputs must be same as the names given in the parameters.');
end

for i = 1 : m
    % field name
    nm = varargin{i};

    % output
    varargout{i} = zeros(dims{:});
    for j = 1 : n
        if isfield(A{j}, nm)
            varargout{i}(j) = A{j}.(nm);
        end
    end
end
