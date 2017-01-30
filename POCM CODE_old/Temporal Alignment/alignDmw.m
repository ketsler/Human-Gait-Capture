% --- DMW main function ---
%
% Author: Dian Gong
% Date: Written in 2010 and Revised in 2012
% Reference: http://www-scf.usc.edu/~diangong/DMW.html
% Paper: Dynamic Manifold Warping, ICCV2011, Dian Gong and Gerard Medioni
%
% ------------------
% Function: temporal alignment, incldues several options, assume action clip is well segemented
% --- Method 1: Perform 1-D manifold matching with one-side DTW, 
% --- Method 2 and others: see notes in the code
% --- Note: spatial mataching is also includes, but how to use this depends on problems
%           if use "matchingDisAlign" and "matchingDisAlignDynamic", a
%           weighted combination is needed (manual set or CV-training)
% Input: 
% --- P1: the joint-position time series data of seq1
% --- P2: the joint-position time series data of seq2
% --- Dim1: dimension of the raw space of seq1, can be 3 or 2
% --- Dim2: dimension of the raw space of seq2, can be 3 or 2
%
% Output: 
% --- Matching: temporal alignment results
% --- matchingDisL2: distance between seq1&seq2 based on L2 norm (if possible)
% --- matchingDisAlign: distance between seq1&seq2 based on spatial matching
% --- matchingDisAlignDynamic: distance between dynamics of seq1&seq2 based on spatial matching
%
% ------------------

function [Matching, matchingDisL2, matchingDisAlign, matchingDisAlignDynamic] = alignDmw( P1, P2, Dim1, Dim2, varargin )

matchingDisL2 = 0;
matchingDisAlign = 0;
matchingDisAlignDynamic = 0;
if size(P1,1) > size(P2,1); 
  %%warning('usually reference/first sequences have smaller action length'); 
end

% Parsing parameters
[Method, Index, List, Id, Vis, SC] = process_options(varargin ...
  , 'Method', 0 ... % method of alignment
  , 'Index', 0 ... % index of available positions
  , 'List', [] ... % links between positions for visualization
  , 'Id', [] ... % which one is the testing sequence, default is seq 1
  , 'Vis', 0 ... % visualization or not
  , 'SC', 0 ... % SC band for DTW (between 0 and 1)
);

% step 1: compute the latent 1-D manifold coordinate
% note: a approx version of DMW without use the iterative voting procedure
Dis_P1(1) = 0;
for i = 1 : size( P1, 1 ) - 1
    Dis_P1(i+1) = norm( P1(i+1,:) - P1(i,:) );
end
Length_P1 = sum( Dis_P1 );
for i = 1 : size(P1,1)
    Latent_P1(i) = sum(Dis_P1(1:i)) / Length_P1;
end

Dis_P2(1) = 0;
for i = 1 : size( P2, 1 ) - 1
    Dis_P2(i+1) = norm( P2(i+1,:) - P2(i,:) );
end
Length_P2 = sum( Dis_P2 );
for i = 1 : size(P2,1) 
    Latent_P2(i) = sum(Dis_P2(1:i)) / Length_P2;
end

% step 2: temporal mathcing two sequences
if Method == 1 % 1-D manifold alignment with one-side DTW
    % first assume 1st frame in seq1 is linked with 1st frame in seq2
    Matching(1) = 1;
    % One-side DTW without dynamic programming
    for i = 2 : length(Latent_P1)
        [min_dis, index] = min( abs( Latent_P2(Matching(i-1):end) - Latent_P1(i) ) );
        Matching(i) = index + Matching(i-1) - 1;
    end
    
elseif Method == 2 % Two-side DTW without 1-D manifold reduction / classical DTW
    D1 = size(P1,2);
    D2 = size(P2,2);
    for i = 1 : size(P1,1)
        for j = 1 : size(P2,1);
            if (Dim1 == 3 & Dim2 == 3) | (Dim1 == 2 & Dim2 == 2)
                D_dtw(i,j) = norm(P1(i,:)-P2(j,:))^2;
            else 
                error('DTW can not handle inter-domain issue.');
            end
        end
    end
%     [v, S] = dtwFord(D_dtw);
%     P = dtwBack(S);
    Xs{1}=P1';
    Xs{2}=P2';
    ali0 = dtw(Xs); % require the library for dtw!
    Matching = alighPathDtw( ali0.P, 1 );
    
elseif Method == 3 % CTW, temporal add in for testing the results by CTW, Feb. 28 Dian Gong
    %1. Use DTW as initialization 
%     Xs{1}=P1';
%     Xs{2}=P2';
%     ali0 = dtw(Xs);
    %2. Use uniform as initialization
    Matching = 1 : (size(P2,1)-1)/(size(P1,1)-1) : size(P2,1);
    Matching = floor( Matching );
    Matching(1) = 1;
    Matching(end) = size(P2,1);
    ali0.alg = [];
    ali0.P = alighPathDtw( Matching, 2 );
    ali0.acc = [];
    ali0.tim = [];
    ali0.obj = [];
    ali0.dif = [];
    
    % CTW
    Xs{1}=P1';
    Xs{2}=P2';
    parCtw.th = 0; parCtw.debg = 'n'; parCtw.PT = [];
    parCca.egy = .95; 
    parCca.b = 3; 
    parCca.reg = 'fix'; 
    parCca.k = 5; 
    parCca.mis = [1; 1] * 1e-4;
    [ali, Ys, Vs, objs, its] = ctw(Xs, ali0, parCtw, parCca);
    Matching = Alighpath_DTW_Manifold( ali.P, 1 );

elseif Method == 4 % PCA + one-side DTW
    Cov1 = (P1 - ones(size(P1,1),1)*mean(P1))'*(P1 - ones(size(P1,1),1)*mean(P1));
    [V_cov1,D_cov1] = eig(Cov1);
    [lambda1,index_lambda1] = max(diag(D_cov1));
    P1_dim = (P1 - ones(size(P1,1),1)*mean(P1)) * V_cov1(:,index_lambda1);
    Cov2 = (P2 - ones(size(P2,1),1)*mean(P2))'*(P2 - ones(size(P2,1),1)*mean(P2));
    [V_cov2,D_cov2] = eig(Cov2);
    [lambda2,index_lambda2] = max(diag(D_cov2));
    P2_dim = (P2 - ones(size(P2,1),1)*mean(P2)) * V_cov2(:,index_lambda2);
    
    P1_dim = ( P1_dim - min(P1_dim) ) / ( max(P1_dim) - min(P1_dim) );
    P2_dim = ( P2_dim - min(P2_dim) ) / ( max(P2_dim) - min(P2_dim) );
    if P1_dim(end) <= P1_dim(1)
        P1_dim = P1_dim(end:-1:1);
    end
    if P2_dim(end) <= P2_dim(1)
        P2_dim = P2_dim(end:-1:1);
    end
    Matching(1) = 1;
    for i = 2 : length(P1_dim)
        [min_dis, index] = min( abs( P2_dim(Matching(i-1):end) - P1_dim(i) ) );
        Matching(i) = index + Matching(i-1) - 1;
    end
    
elseif Method == 5 % Global Optimal DTW plus Local CCA
    D1 = size(P1,2);
    D2 = size(P2,2);
    for i = 1 : size(P1,1)
        for j = 1 : size(P2,1);
            if Dim1 == 3 && Dim2 == 3
                [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/3, 3 ), reshape( P2(j,:), D2/3, 3 ) );
                D_CCA(i,j) = norm(U-V);
            elseif Dim1 == 2 && Dim2 == 3
                [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/2, 2 ), reshape( P2(j,:), D2/3, 3 ) );
                D_CCA(i,j) = norm(U-V);
            end
        end
    end
    [v, S] = dtwFord(D_CCA);
    P = dtwBack(S);
    Matching = alighPathDtw( P, 1 );    
    
elseif Method == 6 % Two-side Advanced DTW / With SC band
    D1 = size(P1,2);
    D2 = size(P2,2);
    Xs{1}=P1';
    Xs{2}=P2';
    DistM = conDst(Xs{1}, Xs{2});
    DistM = dtwBand( DistM, 'SC', SC );
    [~, S] = dtwFordSlow(DistM);
    P = dtwBackSlow(S);
    Matching = alighPathDtw( P, 1 );

end
    

% % step 2: select motion by the Index. 
% % --- it is important to perform this after temporal alignment, otherwise we re-leaen the manifold of the labeled sequence---
% if sum(Index) > 0
%     Index_map = zeros(1,size(P1,2)/Dim1);
%     Index_map(Index) = 1;
%     Index_non = find(1-Index_map);
%     D1 = size(P1, 2);
%     D2 = size(P2, 2);
%     if Id == 1 % P1 is unlabeled (testing), P2 is labeled (training)
%         if Dim2 == 3
%             P2 = [ P2( :, Index ) P2( :, Index + D2/Dim2 ) P2( :, Index + 2*D2/Dim2 )];
%         else
%             P2 = [ P2( :, Index ) P2( :, Index + D2/Dim2 )];
%         end 
%     else % P2 is unlabeled, P1 is labeled
%          if Dim1 == 3
%             P1 = [ P1( :, Index ) P1( :, Index + D1/Dim1 ) P1( :, Index + 2*D1/Dim1 )];
%         else
%             P1 = [ P1( :, Index ) P1( :, Index + D1/Dim1 )];
%         end
%     end
% end
%     
% 
% % step 3: spatial matching with local canonical correlation analysis (LCCA)
% D1 = size(P1,2);
% D2 = size(P2,2);
% matchingDisL2 = zeros( size(P1,1), 1 );
% matchingDisAlign = zeros( size(P1,1), 1 );
% matchingDisAlignDynamic = zeros( size(P1,1)-1, 1 );
% 
% for i = 1 : size(P1,1)
%     if D1 == D2 % natural L2-distance can be cacluated
%         matchingDisL2(i) = norm( P1(i,:) - P2(Matching(i),:) );
%     else
%         matchingDisL2(i) = 0;
%     end
%     % CCA Alignment distance metric is cacluated
%     if Dim1==3 && Dim2 == 3
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/3, 3 ), reshape( P2(Matching(i),:), D2/3, 3 ) ); % CCA on per frame
%     elseif Dim1==2 && Dim2 == 2
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/2, 2 ), reshape( P2(Matching(i),:), D2/2, 2 ) ); % CCA on per frame
%     elseif Dim1==3 && Dim2 == 2
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/3, 3 ), reshape( P2(Matching(i),:), D2/2, 2 ) ); % CCA on per frame
%     elseif Dim1==2 && Dim2 == 3
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1(i,:), D1/2, 2 ), reshape( P2(Matching(i),:), D2/3, 3 ) ); % CCA on per frame
%     end
%     matchingDisAlign(i) = norm( U - V );
% end
% matchingDisL2 = matchingDisL2 / size(P1,1);
% matchingDisAlign = matchingDisAlign / size(P1,1);
% 
% % Dynamic frames distance
% for i = 1 : size(P1,1)-1
%     P1_dynamic = P1(i,:) - P1(i+1,:);
%     if Matching(i) < Matching(i+1) 
%         P2_dynamic = P2(Matching(i),:) - P2(Matching(i+1),:);
%     else
%         if Matching(i)+1 > size(P2,1) % This is a issue, what happen if last few frames in P2 has the same corresponding frames in P1
%             P2_dynamic = P2(Matching(i),:) - P2(Matching(i)-1,:);
%         else
%             P2_dynamic = P2(Matching(i),:) - P2(Matching(i)+1,:);
%         end
%     end
%     if Dim1==3 && Dim2 == 3
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1_dynamic, D1/3, 3 ), reshape( P2_dynamic, D2/3, 3 ) ); % CCA on per frame
%     elseif Dim1==2 & Dim2 == 2
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1_dynamic, D1/2, 2 ), reshape( P2_dynamic, D2/2, 2 ) ); % CCA on per frame
%     elseif Dim1==3 & Dim2 == 2
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1_dynamic, D1/3, 3 ), reshape( P2_dynamic, D2/2, 2 ) ); % CCA on per frame
%     elseif Dim1==2 & Dim2 == 3
%         [A,B,r,U,V,stats] = canoncorr( reshape( P1_dynamic, D1/2, 2 ), reshape( P2_dynamic, D2/3, 3 ) ); % CCA on per frame
%     end
%     matchingDisAlignDynamic(i) = norm( U-V );
% end
% matchingDisAlignDynamic = matchingDisAlignDynamic / (size(P1,1)-1);
% 
% % Visualization - visualize the temporal align results
% if Vis == 1
%   for i = 1 : size(P1,1);
%     if (Dim1 == 3) && (Dim2 == 3)        
%       
%         subplot(1,2,1);
%         plot3( P1(i,1:D1/3), P1(i,1+D1/3:2*D1/3), P1(i,2*D1/3+1:D1), 'b.', 'MarkerSize', 18 ); axis equal;
%         drawLines3(P1(i,:), List); xlabel( strcat( num2str(i), '/', num2str(size(P1,1) ) ),'FontSize', 20, 'Color', 'red' ); pause(0.02); 
%         
%         subplot(1,2,2); 
%         plot3( P2(Matching(i),1:D2/3), P2(Matching(i),1+D2/3:2*D2/3), P2(Matching(i),2*D2/3+1:D2), 'b.', 'MarkerSize', 18 ); axis equal;
%         drawLines3(P2(Matching(i),:), List); xlabel( strcat( num2str(Matching(i)), '/', num2str(size(P2,1) ) ),'FontSize', 20, 'Color', 'red' ); pause(0.02);
%         
%     elseif (Dim1 == 2) && (Dim2 == 2)
%         subplot(1,2,1); plot( P1(i,1:D1/2), P1(i,1+D1/2:D1), 'b.' ); axis equal; 
%         drawLines2(P1(i,:), List); xlabel(i); pause(0.02);
%         subplot(1,2,2); plot( P2(Matching(i),1:D2/2), P2(Matching(i),1+D2/2:D2), 'b.' ); axis equal; 
%         drawLines2(P2(Matching(i),:), List); xlabel(Matching(i)); pause(0.02); 
%     elseif (Dim1 == 3) && (Dim2 == 2)
%         subplot(1,2,1); plot3( P1(i,1:D1/3), P1(i,1+D1/3:2*D1/3), P1(i,2*D1/3+1:D1), 'b.', 'MarkerSize', 20 ); axis equal; xlabel(i); pause(0.02);
%         subplot(1,2,2); plot( P2(Matching(i),1:D2/2), P2(Matching(i),1+D2/2:D2), 'b.', 'MarkerSize', 20 ); axis equal; xlabel(Matching(i)); pause(0.02);
%     elseif (Dim1 == 2) && (Dim2 == 3)
%         subplot(1,2,1); plot( P1(i,1:D1/2), P1(i,1+D1/2:D1), 'b.', 'MarkerSize', 20  ); axis equal; xlabel(i); pause(0.02);
%         subplot(1,2,2); plot3( P2(Matching(i),1:D2/3), P2(Matching(i),1+D2/3:2*D2/3), P2(Matching(i),2*D2/3+1:D2), 'b.', 'MarkerSize', 20 ); axis equal; xlabel(Matching(i)); pause(0.02);
%     end
%   end
% end