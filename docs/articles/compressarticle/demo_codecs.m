%%
% close all;
figure(1);
for k=0:3
    fs=2^k*300;
    t=0:1/fs:.02;
    x=cos(2*pi*100*t);
    y=cos(2*pi*200*t);
    subplot(2,2,3-k+1);
    plot(t,x,'r+',t,y,'bo',t,x,'r',t,y,'b');
end
%%
% figure(2);
% q=zeros(1,145);
% samp=q;
% for k=1:10
%     q([0:15]*9+k)=-8:7;
%     samp([0:15]*9+k)=[0:15]+k/10;
% end
% subplot(2,1,1);
% plot(samp,q,'.');
% for k=1:10
%     q([0:15]*9+k)=2.^[-8:7]/(128/15)-8;
%     samp([0:15]*9+k)=[0:15]+k/10;
% end
% subplot(2,1,2);
% plot(samp,q,'.');
%%
fs=2000;
t=0:1/fs:.02;
x=cos(2*pi*100*t);
figure(3);
hold on;
subplot(2,1,1);
plot(t,x,'r');
subplot(2,1,2);
stem(t,x,'r');
hold off;
%%
% t=1:1000;
% x=sin(2*pi/8000*1000*t);
% y=sin(2*pi/8000*1010*t);
% z=sin(2*pi/8000*1700*t);
% out1=[x,x+y,x+z];
% out2=[x,x+y/10,x+z/10];
% figure(4);
% p1=psd(spectrum.periodogram,out2,'fs',8000);
% t=1:16000;
% x=sin(2*pi/8000*1000*t);
% y=sin(2*pi/8000*1010*t);
% z=sin(2*pi/8000*1700*t);
% out1=[x,x+y,x+z];
% out2=[x,x+y/10,x+z/10];
% p2=psd(spectrum.periodogram,out2,'fs',8000);
% title('Power Spectral Density Estimate via Periodogram');
% subplot(2,2,1);plot(p1.Frequencies,10*log10(p1.Data));
% ylabel('Power/Frequency (dB/Hz)');
% xlabel('Frequency(hz)');
% r1=450:600;
% subplot(2,2,2);plot(p1.Frequencies(r1),10*log10(p1.Data(r1)));
% xlabel('Frequency(hz)');
% subplot(2,2,3);plot(p2.Frequencies,10*log10(p2.Data));
% ylabel('Power/Frequency (dB/Hz)');
% xlabel('Frequency(hz)');
% r2=8100:8400;
% subplot(2,2,4);plot(p2.Frequencies(r2),10*log10(p2.Data(r2)));
% xlabel('Frequency(hz)');
%%
figure(5);
if z==999
    [z0,fs,bits]=wavread('c:\Documents and Settings\goldfita\Desktop\mp.wav');
    numpts=100;
    z=z0(4000:(4000+numpts-1));
    t=0/fs:1/fs:((numpts-1)/fs);
end
pow=3;
subplot(2,1,1);
plot(t,z/max(abs(z)),t,(floor((z/max(abs(z))-.00000001)*2^(pow-1))+.5)/2^(pow-1));
title('Quantization');
ylabel('3 bits');
pow=4;
subplot(2,1,2);
plot(t,z/max(abs(z)),t,(floor((z/max(abs(z))-.00000001)*2^(pow-1))+.5)/2^(pow-1));
ylabel('4 bits');
%%
figure(6);
numpts=1000;
t=0/fs:1/fs:((numpts-1)/fs);
z=z0(5000:5000+numpts-1);
z2=z(2:end)-z(1:end-1);
plot(t(1:end-1),z(1:end-1),'b',t(1:end-1),z2,'r');
legend('segment of "one"','differential');

figure(7);
[hbinsz,posz]=hist(z,50);
[hbinsz_10,posz_10]=hist(z/10,50);
[hbinsz2,posz2]=hist(z2,50);
subplot(3,1,1);bar(posz,hbinsz,'hist');
title('Signals Histogram');
ylabel('original');
subplot(3,1,2);bar(posz_10,hbinsz_10,'hist');
ylabel('original/10');
subplot(3,1,3);bar(posz2,hbinsz2,'hist');
ylabel('difference');
