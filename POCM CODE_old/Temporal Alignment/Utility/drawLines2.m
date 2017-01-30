function drawLines2(P, list)
D = size(P,2)/2;
hold on
for i=1:length(list)
    h = plot( [P(list(i,1)) P(list(i,2))], [P(list(i,1)+D) P(list(i,2)+D)], 'k-', 'lineWidth', 3 );
end;
hold off