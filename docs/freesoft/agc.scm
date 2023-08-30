;;;Todd Goldfinger
;;;GPL 2.0

;(use-modules (ice-9 format))
(use-modules (srfi srfi-13))

(define AGC-dialog #f)
(define fname "out.wav")
(define flen "256")


;;;Called when AGC menu option is chosen.
;;;Automatically saves file and opens the AGC version in another frame.
(define (do-agc file-name frame-len)
  (begin
    (save-selection file-name :header-type (header-type) :data-format mus-lshort)
    (open-sound file-name)
    (process-frames! (string->number frame-len))
    (save-sound)))

(define todds-menu (add-to-main-menu "Todd's Tricks"))
(add-to-menu todds-menu "AGC" (lambda () (AGC-dialog (cadr (main-widgets)))))

;;;Some over a given range.
(define (sum-range v start end)
  (letrec ((last (abs (vct-ref v end)))
	   (do-sum (lambda (cur)
		     (if (< cur end)
			 (+ (abs (vct-ref v cur)) (do-sum (+ cur 1)))
			 last))))
    (do-sum start)))

;;;Divide a frame by denom.
;;;Multiply by a scaling factor to avoid overflow.
(define (div-range! v denom start end)
  (do ((i start (+ i 1))) ((> i end))
       (vct-set! v i (* (/  (vct-ref v i) denom) .1))))

;;;Zero frame.
(define (zero-range! v start end)
    (do ((i start (+ i 1))) ((> i end))
      (vct-set! v i 0)))

;;;Loop through file running AGC on each frame.
(define (process-frames! frame-len)
  (let* ((v (samples))
	 (len (vct-length v)))
    (do ((i 0 (+ i frame-len))) ((> i len))
      (let* ((next (if (> (+ i (- frame-len 1)) len) 
		       (- len 1) 
		       (+ i (- frame-len 1))))
	     (sum (sum-range v i next)))
	(if (< sum (* frame-len .02));don't amplify noise
	    (zero-range! v i next)
	    (div-range! v (/ sum (+ (- next i) 1)) i next))))
    (set-samples 0 len v)));save vct back to snd

;;;Bind C-x a to AGC under Todd's Tricks
(bind-key (char->integer #\a) 4
	  (lambda ()
	    "run AGC"
	    (AGC-dialog (cadr (main-widgets))))
	  #t)

;;;Taken from a demo file.
(define* (g_signal_connect obj name func #:optional data)
  ;; slightly obsolete ...
  (g_signal_connect_closure_by_id 
   (list 'gpointer (cadr obj))
   (g_signal_lookup name (G_OBJECT_TYPE (GTK_OBJECT obj)))
   0
   (g_cclosure_new func data (list 'GClosureNotify 0))
   #f))

(define (AGC-dialog parent)
  (begin
    (set! AGC-dialog (gtk_dialog_new))
    (gtk_widget_set_size_request AGC-dialog 350 100)
    (gtk_window_set_title (GTK_WINDOW AGC-dialog) "Auto Gain")
    (gtk_widget_realize AGC-dialog)
    ;;;Build widgets
    (let* ((pane (gtk_hbox_new #f 0))
	   (pane-entry (gtk_hbox_new #f 0))
	   (pane-entry1 (gtk_vbox_new #f 0))
	   (pane-entry2 (gtk_vbox_new #f 0))
	   (desc-frame (GTK_LABEL (gtk_label_new "Frame Length ")))
	   (desc-file (GTK_LABEL (gtk_label_new "File Name        ")))
	   (done (gtk_button_new_with_label "Process"))
	   (file (GTK_EDITABLE (gtk_entry_new)))
	   (frame (GTK_EDITABLE (gtk_entry_new))))

      (gtk_editable_insert_text file fname -1)
      (gtk_editable_insert_text frame flen -1)

      ;;;Assembly GUI
      (gtk_box_pack_start (GTK_BOX pane-entry1) (GTK_WIDGET desc-file) #t #t 5)
      (gtk_box_pack_start (GTK_BOX pane-entry1) (GTK_WIDGET desc-frame) #t #t 5)
      (gtk_box_pack_start (GTK_BOX pane-entry2) (GTK_WIDGET file) #f #t 0)
      (gtk_box_pack_start (GTK_BOX pane-entry2) (GTK_WIDGET frame) #f #t 0)
      (gtk_box_pack_start (GTK_BOX pane-entry) pane-entry1 #f #t 0)
      (gtk_box_pack_start (GTK_BOX pane-entry) pane-entry2 #f #t 0)
      (gtk_box_pack_start (GTK_BOX pane) pane-entry #f #t 0)
      (gtk_box_pack_start (GTK_BOX pane) done #t #t 2)
      (gtk_box_pack_start (GTK_BOX (.action_area (GTK_DIALOG AGC-dialog))) pane #t #t 0)

      ;;;Catch process event
      (g_signal_connect done "clicked"
			(lambda (w info)
			  (let ((file-name (gtk_entry_get_text (GTK_ENTRY file)))
				(frame-len (gtk_entry_get_text (GTK_ENTRY frame))))
			    (gtk_widget_hide AGC-dialog)
			    (do-agc file-name frame-len))))
      ;;;Display widgets
      (gtk_widget_show pane)
      (gtk_widget_show pane-entry)
      (gtk_widget_show pane-entry1)
      (gtk_widget_show pane-entry2)
      (gtk_widget_show done)
      (gtk_widget_show (GTK_WIDGET desc-file))
      (gtk_widget_show (GTK_WIDGET desc-frame))
      (gtk_widget_show (GTK_WIDGET file))
      (gtk_widget_show (GTK_WIDGET frame))))
  (gtk_widget_show AGC-dialog))

