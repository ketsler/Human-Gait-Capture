function drawLines3(P, list)
D = size(P,2)/3;
hold on
for i=1:size(list,1)
    h = plot3( [P(list(i,1)) P(list(i,2))], [P(list(i,1)+D) P(list(i,2)+D)], [P(list(i,1)+2*D) P(list(i,2)+2*D)], 'k-', 'lineWidth', 3 );
end;
hold off