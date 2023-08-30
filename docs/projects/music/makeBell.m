%make a cool bell sound using additive synthesis

dur=3;
amp=1;
ff=330;
fs=5000;

t=0:1/fs:dur-1/fs;

f1=sin(2*pi*ff*.56*t);
a1=exp(-t/dur);
out1=generalSine(a1,f1,fs);

f2=sin(2*pi*(ff*.56+1)*t);
a2=.67*exp(-t/(dur*.9));
out2=generalSine(a2,f2,fs);

f3=sin(2*pi*ff*.92*t);
a3=exp(-t/(dur*.65));
out3=generalSine(a3,f3,fs);

f4=sin(2*pi*(ff*.92+1.7)*t);
a4=1.8*exp(-t/(dur*.55));
out4=generalSine(a4,f4,fs);

f5=sin(2*pi*ff*1.19*t);
a5=2.67*exp(-t/(dur*.325));
out5=generalSine(a5,f5,fs);

f6=sin(2*pi*ff*1.7*t);
a6=1.67*exp(-t/(dur*.35));
out6=generalSine(a6,f6,fs);

f7=sin(2*pi*ff*2*t);
a7=1.46*exp(-t/(dur*.25));
out7=generalSine(a7,f7,fs);

f8=sin(2*pi*ff*2.74*t);
a8=1.33*exp(-t/(dur*.2));
out8=generalSine(a8,f8,fs);

f9=sin(2*pi*ff*3*t);
a9=1.33*exp(-t/(dur*.15));
out9=generalSine(a9,f9,fs);

f10=sin(2*pi*ff*3.76*t);
a10=exp(-t/(dur*.1));
out10=generalSine(a10,f10,fs);

f11=sin(2*pi*ff*4.07*t);
a11=1.33*exp(-t/(dur*.075));
out11=generalSine(a11,f11,fs);

out=out1+out2+out3+out4+out5+out6+out7+out8+out9+out10+out11;
