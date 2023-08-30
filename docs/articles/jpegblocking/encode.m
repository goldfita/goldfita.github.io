function Y=encode(X,quality)
% Modified by Todd Goldfinger (originally blkdct2)
% 
% compute the 2D dct of mxn sub-blocks of X
% m must divide the # of rows of X
% n must divide the # of columns of X 
% for small blocks the dct2 is computed faster by matrix multiplication
% that by using the dct2 command
%
% quantizes image as it does the dct
qnt=1/quality*[16 11 10 16 24 40 51 61; 12 12 14 19 26 58 60 55; 14 13 16 24 40 57 69 56; 14 17 22 29 51 87 80 62; 18 22 37 56 68 109 103 77; 24 35 55 64 81 104 113 92; 49 64 78 87 103 121 120 101; 72 92 95 98 112 100 103 99];
m=8;n=8;
[r,s] = size(X);
Y = zeros(r,s);
C1 = dct(eye(m));
C2 = dct(eye(n))';
for i=1:(r/m)
    for j=1:(s/n)
        e = (i-1)*m+1;
        f = (j-1)*n+1;
        Z = X(e:(e+m-1),(f:f+n-1));
        Y(e:(e+m-1),(f:f+n-1)) = round((C1*Z*C2)./qnt);
    end;
end;
