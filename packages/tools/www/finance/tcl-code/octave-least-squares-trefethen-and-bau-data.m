x = -5:5;
y = [0,0,0,1,1,1,0,0,0,0,0];
plot(x,y,'*k');
set(gca, 'ylim', [-1,5]);
format short e;
p1 = polyfit(x,y,10);
p1
xDense = -5:0.1:5;
y1 = polyval(p1,xDense);
plot(xDense,y1);
hold on;
plot(x,y,'*k');
format short;
p2 = polyfit(x,y,5)
y2 = polyval(p2,xDense);
hold off;
plot(xDense, y2);
hold on;
plot(x,y,'*k');
set(gca, 'ylim', [-1,5]);
