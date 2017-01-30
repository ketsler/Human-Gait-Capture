function [X, G] = genGausses(mes, Vars, ns0, varargin)
% Generate samples from the specified Gaussian distribution.
%
% Input
%   mes     -  mean, dim x k
%   Vars    -  variance, dim x dim x k
%   ns      -  #samples
%   varargin
%     bdN   -  boundary of variance of sample number, {[.8, 1.2]}
%
% Output
%   X       -  sample matrix, dim x n
%   G       -  class indicator matrix, k x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-20-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 06-02-2010

% function option
bdN = ps(varargin, 'bdN', [.8 1.2]);

[dim, k] = size(mes);

% sample number
if length(ns0) == 1
    ns0 = ones(1, k) * ns0;
end

ns = zeros(1, k);
for c = 1 : k
    ns(c) = genUnifD(bdN(1) * ns0(c), bdN(2) * ns0(c), 1);
end

% sample
Xs = cell(1, k);
for c = 1 : k
    Xs{c} = genGauss(mes(:, c), Vars(:, :, c), ns(c));
end
X = cat(2, Xs{:});
[tmp, G] = n2s(ns);
