function setPromL(level)
% Set level of prompt that display the information on screen.
%
% Input
%   level     -  level of prompt, 't' | 'm' | 'b'
%
% History
%   create    -  Feng Zhou (zhfe99@gmail.com), 08-21-2009
%   modify    -  Feng Zhou (zhfe99@gmail.com), 08-16-2010

global promL;

if level ~= 't' && level ~= 'm' && level ~= 'b'
    error(['unknown level: ' level]);
end
promL = level;
