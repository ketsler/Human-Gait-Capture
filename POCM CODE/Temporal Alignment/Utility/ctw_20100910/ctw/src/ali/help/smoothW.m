function W = smoothW(W0)

[v, P] = dtakFord(W0);
C = dtakBack(P);
W = C2W(C);
