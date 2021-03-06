function value = ps(option, name, default)
% Fetch the content of the specified field within a struct or cell array.
% If the field does not exist, use the default value instead.
%
% Example1 (when option is a struct):
%   input    -  option.lastname = 'feng';
%   call     -  value = ps(option, 'lastname', 'noname');
%   output   -  value = 'feng'
%
% Example2 (when option is a cell array):
%   input    -  option = {'lastname', 'feng'};
%   call     -  value = ps(option, 'lastname', 'noname');
%   output   -  value = 'feng'
%
% Input
%   option   -  struct or cell array
%   name     -  field name
%   default  -  default field value
%
% Output
%   value    -  the field value
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-04-2010

if iscell(option)
    if isempty(option)
        option = [];
    elseif length(option) == 1
        option = option{1};
    else
        option = cell2option(option);
    end
end

if isfield(option, name)
    value = option.(name);
else
    value = default;
end
