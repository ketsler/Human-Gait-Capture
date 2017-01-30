%clear variables;
tag = 3; svL = 1;

%% src
wsSrc = toyAliSrc(tag, 'prex', tag, 'svL', svL, 't', 200);
[Xs, aliT] = stFld(wsSrc, 'Xs', 'aliT');

%% init from dtw
ali0 = dtw(Xs);

%% ctw
parCtw.th = 0; parCtw.debg = 'y'; parCtw.PT = aliT.P;
parCca.egy = .95; parCca.b = 3; parCca.reg = 'cross'; parCca.k = 5; parCca.mis = [1; 1] * 1e-4;
[ali, Ys, Vs, objs, its] = ctw(Xs, ali0, parCtw, parCca);

%% sh
rows = 2; cols = 2;
axs = iniAx(3, rows, cols, [300 * cols, 300 * rows]);
mkSiz = 3;
shSeq(Xs, 'ax', axs{1, 1}, 'lnWid', 1, 'mkSiz', mkSiz, 'mkEg', 'n');
shSeq(Ys, 'ax', axs{1, 2}, 'lnWid', 1, 'mkSiz', mkSiz, 'mkEg', 'n');
shAlis({aliT, ali0, ali}, 'ax', axs{2, 1}, 'algs', {'truth', 'dtw', 'ctw'});
shIter(objs, its, 'ax', axs{2, 2});