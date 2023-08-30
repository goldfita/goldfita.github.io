function out=generalSine(amp,freq,fs)


out=amp.*sin(2*pi*cumsum(freq)/fs);
