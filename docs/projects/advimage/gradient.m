function [p, q, magnitude]=gradient(A)

%define a Sobel gradient operator
[xSize, ySize]=size(A);


H1=[-1 0 1;-2 0 2;-1 0 1];
H2=[-1 -2 -1; 0 0 0;1 2 1];

G1=conv2(A,H1, 'same');
G2=conv2(A,H2, 'same');

scale1=max(max(G1));
scale2=max(max(G2));

p=G1;

q=G2;

G=abs(G1)+abs(G2);

magnitude=G;

