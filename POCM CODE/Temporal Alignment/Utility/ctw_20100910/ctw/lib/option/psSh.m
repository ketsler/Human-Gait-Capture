function [h0, ax, fig] = psSh(option)
% Parse the common option for sh* functions.
%
% Input
%   name    -  option name, 'fig' | 'ax' | 'cla' | 'h0'
%   value   -  option value
% 
% Output
%   h0      -  initial handle
%   ax      -  handle for axes
%   fig     -  figure number
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-21-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-29-2010

% fig
fig = ps(option, 'fig', []);
if length(fig) == 1
    figure(fig); clf('reset');

elseif length(fig) == 4
    figure(fig(1));
    subplot(fig(2), fig(3), fig(4), 'replace');
end

% axes
ax = ps(option, 'ax', []);
isCla = psY(option, 'cla', 'y');
if ~isempty(ax)
    hf = get(ax, 'Parent');
    figure(hf);
    set(hf, 'CurrentAxes', ax);
    
    if isCla
        cla;
    end
end

% h0
h0 = ps(option, 'h0', []);
