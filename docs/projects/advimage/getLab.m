function [L,a,b]=getLab(R,G,B)
%Calculate L*a*b* values given RGB on a scale from 0 to 1

Xw=.3127;
Yw=.3290;
Zw=.3583;

h1=inline('q^(1/3)');
h2=inline('7.787*q+16/116');

trans=[.588 .179 .183; .29 .606 .105; 0 .068 1.021];

tristim=trans*[R G B]';

if h1(tristim(1)/Xw)>.008856
   hx=h1(tristim(1)/Xw);
else
   hx=h2(tristim(1)/Xw);
end
if h1(tristim(2)/Yw)>.008856
   hy=h1(tristim(2)/Yw);
else
   hy=h2(tristim(2)/Yw);
end
if h1(tristim(3)/Zw)>.008856
   hz=h1(tristim(3)/Zw);
else
   hz=h2(tristim(3)/Zw);
end   

L=116*hy-16;
a=500*(hx-hy);
b=200*(hy-hz);