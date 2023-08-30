/*
 * Modifications by Todd Goldfinger.
 * The new version will dial a second phone and echo the output
 * there.  It also merges the signal with a file on disk.
 * You can find the original in the apps directory.
 * 
 * Asterisk -- A telephony toolkit for Linux.
 *
 * Echo application -- play back what you hear to evaluate latency
 * 
 * Copyright (C) 1999, Mark Spencer
 *
 * Mark Spencer <markster@linux-support.net>
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License
 */

#include <asterisk/lock.h>
#include <asterisk/file.h>
#include <asterisk/logger.h>
#include <asterisk/channel.h>
#include <asterisk/pbx.h>
#include <asterisk/module.h>
#include <asterisk/translate.h>
#include <asterisk/channel_pvt.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

static char *tdesc = "Simple Echo Application";

static char *app = "test_Echo";

static char *synopsis = "Echo audio read back to a second phone.";

static char *descrip = 
"  test_Echo():  Echo audio read from channel back to another channel. Returns 0\n"
"if the user exits with the '#' key, or -1 if the user hangs up.\n";

STANDARD_LOCAL_USER;

LOCAL_USER_DECL;

static int echo_exec(struct ast_channel *chan, void *data)
{
    int res=-1, i, reason;
    short *data;
    struct localuser *u;
    struct ast_frame *f=NULL,*pframe,*trframe=NULL;
    struct ast_filestream *play;
    struct ast_trans_pvt *trans;
    struct ast_channel *chan2;
    static struct ast_frame null_frame = 
	{
	    AST_FRAME_NULL,
	};
    LOCAL_USER_ADD(u);

    play = ast_openstream(chan,"yourprompt",chan->language);   
    if(!play)
        return -1;
    if(ast_applystream(chan,play))
        return -1;
#if 1
    chan2 = ast_request_and_dial("SIP", AST_FORMAT_SLINEAR, (void*)"1002", 30000, &reason, chan->callerid);
    if(chan2) {
	if(chan2->_state == AST_STATE_UP) {
            ast_log(LOG_NOTICE, "Channel %s was answered.\n", chan2->name);
            ast_set_write_format(chan2, AST_FORMAT_SLINEAR);
            ast_set_read_format(chan2, AST_FORMAT_SLINEAR/*ast_best_codec(chan->nativeformats)*/);
	} else {
            ast_log(LOG_NOTICE, "Channel %s was not answered.\n", chan2->name);
	    ast_hangup(chan2);
	    return -1;
	}
    } else {
	ast_log(LOG_WARNING, "Could not place call.\n");
	return -1; 
    }
    ast_stopstream(chan2); //make sure we're not trying to play something
#endif 

    //trans = ast_translator_build_path(AST_FORMAT_SLINEAR,AST_FORMAT_GSM);
    trans = ast_translator_build_path(AST_FORMAT_SLINEAR,chan->writeformat);
    ast_set_write_format(chan, AST_FORMAT_SLINEAR);
    ast_set_read_format(chan, AST_FORMAT_SLINEAR);
    while(ast_waitfor(chan, -1) > -1) {
	f = ast_read(chan);
	if(!f)
	    break;
        pframe = ast_readframe(play);
        if(!pframe || !pframe->data)
            break;
        data = (short*)f->data;
        if(trframe) {
            for(i=0; i<f->datalen/2 && i<trframe->datalen/2; i++)
                data[i] = data[i]+((short*)trframe->data)[i];
            ast_frfree(trframe);
            trframe = NULL;
        }
        /* Deliver frame immediately */
	f->delivery.tv_sec = 0;
	f->delivery.tv_usec = 0;
	if(f->frametype == AST_FRAME_VOICE) {
            /* Write the frame out to the orignal and new channels. */
	    if(ast_write(chan, f)) 
		break;
#if 1
            if(ast_write(chan2, f)) 
		break;
#endif
	} else if(f->frametype == AST_FRAME_VIDEO) {
	    if(ast_write(chan, f)) 
		break;
	} else if(f->frametype == AST_FRAME_DTMF) {
	    if(f->subclass == '#') {
		res = 0;
		break;
	    } else
		if(ast_write(chan,f))
		    break;
	}
        if (chan->pvt->readtrans) {
            trframe = ast_translate(trans, pframe, 0);
            if (!trframe)
                trframe = &null_frame;
        }
        /* Release the current frame. */
        ast_frfree(f);
        f = NULL;
    }
    if(f)
        ast_frfree(f);
    ast_stopstream(chan);
    /* Release the translator */
    ast_translator_free_path(trans);
    
    //ast_stopstream(chan2);  
    //ast_hangup(chan2);
    LOCAL_USER_REMOVE(u);
    return res;
}


int unload_module(void)
{
    STANDARD_HANGUP_LOCALUSERS;
    return ast_unregister_application(app);
}

int load_module(void)
{
    return ast_register_application(app, echo_exec, synopsis, descrip);
}

char *description(void)
{
    return tdesc;
}

int usecount(void)
{
    int res;
    STANDARD_USECOUNT(res);
    return res;
}

char *key()
{
    return ASTERISK_GPL_KEY;
}
