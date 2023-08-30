/*
  Split a raw (16 bit) audio file wherever silence occurs.

  Todd Goldfinger
  
  This is available under GPL 2.

  -t thresh               (>0 default is 20)
  -s                      (suppress silence)
  -f name                 (input file)
  -d name                 (directory to make)
  gcc wordsplit.c -o wordsplit -Wall -Wstrict-prototypes -O2
*/

#include <sys/types.h>
#include <limits.h>
#include <sys/stat.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#define BUFSIZE 128
#define BUFSIZE2 (BUFSIZE*2)
#define NUMHIGH 200
#define WSDIR "wsplit"

#if SHRT_MIN!=-32768 || SHRT_MAX!=32767 /* two bytes, right? */
#error shorts need to be 2 bytes
#endif

void cleanup(FILE *fin,FILE *fout, char *err, int quit);
void options(int argc, char *argv[], float *thresh, 
	     int *nosilence, char **fname, char **dir);

void cleanup(FILE *fin, FILE *fout, char *err, int quit)
{
    if(fin)
	fclose(fin);
    if(fout)
	fclose(fout);
    if(err)
	fprintf(stderr,"%s\n",err);
    exit(quit);
}

void options(int argc, char *argv[], float *thresh, 
	     int *nosilence, char **fname, char **dir)
{
    int c;

    while((c=getopt(argc,argv,"st:f:d:")) != -1) {
	switch(c) {
	case 's':
	    *nosilence = 0;
	    break;
	case 't':
	    *thresh = atoi(optarg);
	    if(*thresh<=0) {
		fprintf(stderr,"thresh needs to be > 0\n");
		exit(-1);
	    }
	    *thresh = (*thresh*256) * (*thresh*256) * BUFSIZE;
	    break;
	case 'f':
	    *fname = optarg;
	    break;
	case 'd':
	    *dir = optarg;
	    break;
	case '?':
	    exit(-1);
	}
    }
}

int main(int argc, char *argv[])
{
    char outfile[512],*fname=NULL,*dir=NULL;
    short buf[BUFSIZE2];
    int fd=fileno(stdin);
    int frame=0,i,tot,nosilence=1;
    int nsample=0,sampslow;
    int split=0,splitat,res,fnum=1;
    float pow=0,thresh=20*256*20*256.0*BUFSIZE;
    FILE *fout=NULL,*fin=NULL;

    options(argc,argv,&thresh,&nosilence,&fname,&dir);
    dir = dir?dir:WSDIR;
    if(mkdir(dir,S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH))
	if(errno!=EEXIST)
	    cleanup(fin,fout,"mkdir failed",-1);
    snprintf(outfile,512,"%s/0.raw",dir);
    if(!(fout=fopen(outfile,"wb")))
	cleanup(fin,fout,"fopen failed",-1);
    if(fname) {
	if(!(fin=fopen(fname,"rb")))
	    cleanup(fin,fout,"fopen failed",-1);
	fd = fileno(fin);
    }

    memset((void*)buf,0,BUFSIZE2*2);
    while(1) {
	for(tot=0,res=1; res>0 && tot<BUFSIZE2; tot+=res)
	    res=read(fd,buf+frame+tot,BUFSIZE2-tot);
	if(res<=0 || tot!=BUFSIZE2) {
	    if(res==-1)
		cleanup(fin,fout,"read returned -1",res);
	    cleanup(fin,fout,NULL,res);
	}
	
	for(i=0,splitat=-1,sampslow=0; i<BUFSIZE; i++) {
	    pow += ((float)buf[i+frame])*buf[i+frame] - 
		((float)buf[(i+frame-BUFSIZE)&(BUFSIZE2-1)])*
		buf[(i+frame-BUFSIZE)&(BUFSIZE2-1)];
	    if(pow>thresh) {
		nsample++;
		if(nsample>=NUMHIGH)
		    split = 1;
	    } else {
		nsample = 0;
		sampslow++;
		if(split==1) {
		    split = 0;
		    splitat = i;
		    fwrite(buf+frame,sizeof(short),splitat,fout);
		    fclose(fout);
		    snprintf(outfile,512,"%s/%d.raw",dir,fnum++);
		    fout = fopen(outfile,"wb");
#if 0
		    printf("split\n");
#endif
		}
	    }
	}
	if(sampslow<BUFSIZE*.9 || nosilence) {
	    if(splitat==-1)
		fwrite(buf+frame,sizeof(short),BUFSIZE,fout);
	    else
		fwrite(buf+frame+splitat,sizeof(short),BUFSIZE-splitat,fout);
	}
	frame = (frame+BUFSIZE)%BUFSIZE2;
    }

    return 0;
}
