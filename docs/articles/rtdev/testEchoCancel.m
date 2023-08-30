function [error,c]=testEchoCancel(reference,input)
Laec=1024;
BUFFER_COUNT=256;
clear mex;

s=size(reference);
error=zeros(s);
c=zeros(Laec,1);
for k=BUFFER_COUNT:BUFFER_COUNT:length(reference)
    [error(k-BUFFER_COUNT+1:k,:),c]=echocancel(reference(k-BUFFER_COUNT+1:k),input(k-BUFFER_COUNT+1:k,:),c);
end

