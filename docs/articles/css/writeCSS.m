function writeCSS(sig,name)

fid=fopen(sprintf('~/thesis/%s.bin',name),'wb');
fwrite(fid,sig,'double');
fclose(fid);
