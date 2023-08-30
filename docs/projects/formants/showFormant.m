ORD=26;
fs=24000;
dec=10000;
real=1:2:ORD;
imag=2:2:ORD;
xarr=zeros(10,1);
yarr=zeros(10,1);
fig=figure(1);
try; readRTDX(-1); catch; end
if readRTDX(0)~=1, return, end
d=zeros(26,1);
j=0;

while 1
    try
        j=j+1;
        dnew=readRTDX(26);
        if dnew(1:4)~=[-1 -1 -1 -1]', d=dnew; end;
        mag=(d(real)/dec).^2+(d(imag)/dec).^2;
        %ind=find(mag>1);
        forms=abs(atan2(d(imag),d(real)))*fs/(2*pi);
        %forms(ind)=9999999;
        ind=find(forms==0);
        forms(ind)=9999999;
        [xf,xind]=min(forms);
        forms(xind)=9999999;
        [yf,yind]=min(forms);
        disp(sprintf('xf=%f yf=%f mag1=%f mag2=%f',xf,yf,mag(xind),mag(yind)));
        if xf>yf;
            tmp=xf;
            yf=xf;
            xf=tmp;
        end;
        xarr=[xf; xarr(1:end-1)];
        yarr=[yf; yarr(1:end-1)];
        figure(fig);
        %disp(sprintf('mag %f %f freq %f %f',[xm ym xf yf]));
        plot(xarr,yarr,'r+');
        set(fig,'DoubleBuffer','on');
        axis([0 fs/2 0 fs/2]);
        %M(j)=getframe(gcf);
        pause(.02);
    catch
        disp(lasterr);
        disp('closing');
        readRTDX(-1);
        return
    end
end 