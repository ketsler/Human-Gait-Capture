function [dif, nDif] = aliDifOld(ali1, ali2)
% Evaluate the difference between two alignment.
%
% Example
%   assume  -  ali1.C = [1 1 2 3 4 4 4; ...
%                        1 2 3 4 4 5 6];
%           -  ali2.C = [1 2 2 2 2 2 3 4 4; ...
%                        1 1 2 3 4 5 5 5 6];
%   after   -  [dif, nDif] = aliDif(ali1, ali2)
%   then    -  dif = .3, nDif = 8
%
% Input
%   ali1    -  1st alignment
%   ali2    -  2nd alignment
%
% Output
%   dif     -  difference rate
%   nDif    -  difference number between two alignment
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 04-23-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 02-10-2010

if isstruct(ali1)
    C1 = ali1.C;
    C2 = ali2.C;
else
    C1 = ali1;
    C2 = ali2;
end

n1 = C1(1, end);
n2 = C1(2, end);

B1 = boundC(C1);
B2 = boundC(C2);
B = zeros(3, n1);
for i = 1 : n1
    % difference
    B(1, i) = min(B1(1, i), B2(1, i));
    B(2, i) = max(B1(2, i), B2(2, i));

    % overlap
    a = max(B1(1, i), B2(1, i));
    b = min(B1(2, i), B2(2, i));
    B(3, i) = select(a <= b, b - a + 1, 0); 
end
nDif = sum(B(2, :) - B(1, :) + 1 - B(3, :));
nAll = n1 * n2;

dif = nDif / nAll;

%%%%%%%%%%%%%%%%%%%%%%
function B = boundC(C)
% Bound the correspondence in rows.
%
% Example
%   assume  -  C = [1 1 2 3 4 4 4; ...
%                   1 2 3 4 4 5 6];
%   after   -  B = boundC(C)
%   then    -  B = [1 3 4 4; ...
%                   2 3 4 6];
%
% Input
%   C       -  correspondence matrix, 2 x nC 
%
% Output
%   B       -  boundary of each row, 2 x m

nC = size(C, 2);
m = C(1, end);
B = zeros(2, m);

iC = 1;
while iC <= nC
    r = C(1, iC);
    
    jC = iC;
    while jC <= nC && C(1, jC) == r
        jC = jC + 1;
    end
    jC = jC - 1;
    
    if jC > nC
        jC = nC;
    end
    
    B(1, r) = C(2, iC);
    B(2, r) = C(2, jC);
    
    iC = jC + 1;
end
