if z==999
    [z,fs,bits]=wavread('c:\Documents and Settings\goldfita\Desktop\mp.wav');
    numpts=1000;
    z=z(4000:(4000+numpts-1));
    fz=fftshift(fft(z));
    fzpos=fz((numpts/2+1):numpts);
    [s,I]=sort(abs(fzpos),'descend');
    s=fzpos(I);
end

bins=linspace(0,fs/2-fs/numpts,numpts/2);
bins=bins(I);
t=0/fs:1/fs:((numpts-1)/fs);
cnt=1;
for j=[1,2,4,10,100,numpts/2]
    sig=zeros(size(t));
    for k=1:j%(numpts/2)
        ang=angle(s(k));
        if bins(k)~=0
            sig=sig+abs(s(k))*(cos(2*pi*bins(k)*t+ang)+cos(-2*pi*bins(k)*t-ang))/numpts;
        end
    end
    sig=sig+s(find(bins==0))/numpts;
    subplot(6,2,cnt);
    plot(t,sig,'r');
    ylabel(sprintf('N=%d',j))
    if j==1, title('Decomposition'), end
    axis([ 0 numpts/fs -.1 .1]);
    cnt=cnt+1;
    subplot(6,2,cnt);
    plot(t,abs(z'-sig),'b');
    if j==1, title('Error'), end
    axis([ 0 numpts/fs -.1 .1]);
    cnt=cnt+1;
end