%makes a pretty picture in the frequency domain

fs=10000;
t=-2:1/fs:2-1/fs;

aa=sin(2*pi*3*t);
y1=exp(-(abs(t).^1.7)/2)*1000+2000;
y2=-exp(-(abs(t).^1.7)/2)*1000+2000;
y3=[linspace(0,0,fs*1.6) linspace(2200,2600,fs*.15) linspace(0,0,fs*2.25)];
y4=[linspace(0,0,fs*1.6) linspace(2600,2200,fs*.15) linspace(0,0,fs*2.25)];
y5=[linspace(0,0,fs*2.25) linspace(2200,2600,fs*.15) linspace(0,0,fs*1.6)];
y6=[linspace(0,0,fs*2.25) linspace(2600,2200,fs*.15) linspace(0,0,fs*1.6)];

out1=generalSine(aa,y1,fs);
out2=generalSine(aa,y2,fs);
out3=generalSine(aa,y3,fs);
out4=generalSine(aa,y4,fs);
out5=generalSine(aa,y5,fs);
out6=generalSine(aa,y6,fs);

calspec(out1+out2+out3+out4+out5+out6,[],fs);