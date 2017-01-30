% --- DTW with SC band Dist Matrix function ---
%
% Author: Dian Gong
% Date: Writen in 2010 and Revised in 2012
% Reference: http://www-scf.usc.edu/~diangong/DMW.html
% Paper: Dynamic Manifold Warping, ICCV2011, Dian Gong and Gerard Medioni
%
% ------------------
% Function: visulaization the sequence P (joint-position representation)
function DistMatrix = dtwBand( DistMatrix, varargin )

SC = process_options(varargin ...
  , 'SC', 0 ... % SC band for DTW (between 0 and 1)
);

SC = min(SC, 1);

if SC == 0
  return;
else
  n = size( DistMatrix, 1 );
  m = size( DistMatrix, 2 );
  lenM = floor( m * SC );
  lenN = floor( n * SC );
  for i =  1 : lenN
    len = floor( ( (lenN+1-i) / lenN ) * lenM );
    DistMatrix(i, end-len+1:end) = Inf;
  end 
  for i = n : -1 : n - lenN
    len = floor( ( (i - n + lenN) / lenN ) * lenM );
    DistMatrix(i, 1:len) = Inf;
  end
end