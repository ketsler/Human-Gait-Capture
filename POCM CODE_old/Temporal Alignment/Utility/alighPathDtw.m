% Author: Dian Gong
% Date: Writen in 2010 and Revised in 2012
% Reference: http://www-scf.usc.edu/~diangong/DMW.html
% Paper: Dynamic Manifold Warping, ICCV2011, Dian Gong and Gerard Medioni
%
% ------------------
% Function: path transformation between one-sdie and two-side DTW
%
% ------------------
function Matching = alighPathDtw( P, Index )

if ( (size(P,2) == 2) == 0 ) && ((size(P,1) == 1) == 0)
    warning('DTW align path is incorrect');
end

if Index == 1 %two-side to one-side
    ref(1) = 1; % frame index of sequence 1
    for i=2:size(P,1)
        if P(i,1) > ref(end)
            ref = [ref P(i,1)];
        end
    end
    Matching = zeros( 1, max(ref) );
    Matching(1) = 1;
    for i = 2 : length(Matching)-1
        Cur = P(find(P(:,1)==i),2);
        if length(Cur) == 1
            Matching(i) = Cur;
        else
            Matching(i) = Cur(ceil(length(Cur)/2));
        end
    end
    Matching(max(ref)) = P(end,2);
elseif Index == 2 %one-side to two-side
    L = max( [ length(P) max(P) ] );
    Lx = length(P);
    Ly = max(P);
    Matching(1,:) = [1 1];
    t = 1;
    for i = 2 : size(P,2)
        if P(i) == P(i-1)
            t=t+1;
            Matching(t,:) = [Matching(t-1,1)+1 P(i)];
        else
            gap = P(i) - P(i-1);
            for j=1:gap
                t=t+1;
                Matching(t,:) = [Matching(t-1,1) P(i-1)+j];
            end
            t=t+1;
            Matching(t,:) = [Matching(t-1,1)+1 P(i)];
        end
    end
else
    {};
end