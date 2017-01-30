path0 = cd;

cd 'lib/cell';
mex cellss.cpp;
mex oness.cpp;
mex zeross.cpp;
cd(path0);

cd 'lib/label';
mex G2L.cpp;
mex L2G.cpp;
cd(path0);

cd 'src/ali/dtw';
mex dtwFord.cpp;
mex dtwBack.cpp;
cd(path0);

cd 'src/ali/help';
mex rowBd.cpp;
cd(path0);