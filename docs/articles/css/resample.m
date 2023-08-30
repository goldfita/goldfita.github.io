function out=resample(in)
%Resample from 44.1khz to 8khz

[B,A]=ellip(14,.2,65,(14700/2)/(44100/2));%down 3
tmp=filter(B,A,in);
tmp2=in(1:3:end);
clear tmp;
tmp(1:5:length(tmp2)*5)=tmp2;%up 5
clear tmp2;
[B,A]=ellip(12,.2,65,(10500/2)/(73500/2));%down 7
tmp2=filter(B*5,A,tmp);
tmp2=tmp2(1:7:end);
clear tmp;
tmp(1:4:length(tmp2)*4)=tmp2;%up 4
clear tmp2;
[B,A]=ellip(14,.2,65,(14000/2)/(42000/2));%down 3
tmp2=filter(B*4,A,tmp);
tmp2=tmp2(1:3:end);
clear tmp;
tmp(1:4:length(tmp2)*4)=tmp2;%up 4
clear tmp2;
[B,A]=ellip(12,.2,65,(8000/2)/(56000/2));%down 7
tmp2=filter(B*4,A,tmp);
out=tmp2(1:7:end);