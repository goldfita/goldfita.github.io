;;; Copyright (C) 1996,1997 August Hoerandl <hoerandl@elina.htlw1.ac.at>
;;;
;;; Version: 0.3   April 1997
;;;
;;; Modifications by Todd Goldfinger
;;; May 2006
;;;
;;; -uses css with xhtml 1.0
;;; -automatically retrieves colors
;;; -probably will only work in Xemacs
;;; -does not close the buffer you're working in
;;; -added font-lock-constant-face
;;; -fixed a minor problem with unnecessary tags 
;;;  (For some reason, next-property-change appears to be off one character
;;;   on occasion.  This caused text with only one property to be broken up 
;;;   into multiple tags.)
;;; -added new face detection at run-time
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;; 
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;; 
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;;
;;; Commentary:
;;;   convert a fontified buffer to html source - use information
;;;   from font-lock-mode (use colors or bold/italic etc).
;;;
;;; This program is a quick hack: if you like it - use it
;;; You need Xemacs 19.14 (it may not work with Xemacs 19.13 or Emacs 19.30)
;;;
;;; HOWTO:
;;;
;;; setup:
;;;   put this in your .emacs file:    (load "buffer2xhtml")
;;;   or M-x load-file buffer2xhtml.el
;;;
;;; convert file to html:
;;; 1) open a file, fontify (see font-lock.el for help) 
;;; 2) M-x buffer2xhtml and select color/nocolor
;;;    this will change the buffers name to `oldname`.html and
;;;    add all the HTML Tags
;;; 3) save buffer
;;; 4) view with your favorite browser
;;;
;;; change setup:
;;;  change HTML-Tags for start (b2h-start-...) and end (b2h-end-...) of
;;;  each font-face
;;;
;;; TODO:
;;;   - optimize for speed 
;;;   - add hooks for text change - allow easy change ?
;;;   - change all #include "..." to html-references 
;;;   - change all function calls to html-references ?
;;;   - get colors from directly from font-lock-mode


;; version with color
(defvar b2h-start-color
  '((font-lock-comment-face . "<span class=\"flcf\">")
    (font-lock-constant-face . "<span class=\"flconstf\">")
    (font-lock-doc-string-face ."<span class=\"fldsf\">")
    (font-lock-string-face . "<span class=\"flsf\">")
    (font-lock-keyword-face . "<span class=\"flkf\">")
    ;;    create headline for each function
    ;;    (font-lock-function-name-face . "<H2>")
    (font-lock-function-name-face . "<span class=\"flfnf\">")
    (font-lock-variable-name-face . "<span class=\"flvnf\">")
    (font-lock-type-face . "<span class=\"fltf\">")
    (font-lock-reference-face . "<span class=\"flrf\">")
    (font-lock-preprocessor-face . "<span class=\"flpf\">"))
  "Association List for buffer2xhtml (color): font . HTML Tag to start")

;to get color name - (cdadar (specifier-specs sp))
;to get list of faces - font-lock-face-list

(defun face-to-style-str (face prop)
  (let ((rgb (color-rgb-components
              (face-property face 'foreground))))
  (format "span.%s {color:#%02x%02x%02x}\n" 
          prop
          (/ (car rgb) 256) 
          (/ (cadr rgb) 256) 
          (/ (caddr rgb) 256))))


(defvar b2h-rgb-color
  '((font-lock-comment-face . (face-to-style-str 'font-lock-comment-face "flcf"))
    (font-lock-constant-face . (face-to-style-str 'font-lock-constant-face "flconstf"))
    (font-lock-preprocessor-face . (face-to-style-str 'font-lock-preprocessor-face "flpf"))
    (font-lock-string-face . (face-to-style-str 'font-lock-string-face "flsf"))
    (font-lock-doc-string-face . (face-to-style-str 'font-lock-doc-string-face "fldsf"))
    (font-lock-function-name-face . (face-to-style-str 'font-lock-function-name-face "flfnf"))
    (font-lock-variable-name-face . (face-to-style-str 'font-lock-variable-name-face "flvnf"))
    (font-lock-reference-face . (face-to-style-str 'font-lock-reference-face "flrf"))
    (font-lock-keyword-face . (face-to-style-str 'font-lock-keyword-face "flkf"))
    (font-lock-type-face . (face-to-style-str 'font-lock-type-face "fltf"))))


;;; version without color
;(defvar b2h-start-nocolor
;  '((font-lock-comment-face . "<I>")
;    (font-lock-preprocessor-face . "<I>")
;    (font-lock-string-face . "<I>")
;    (font-lock-doc-string-face ."<I>")
;    (font-lock-function-name-face . "<STRONG>")
;    (font-lock-variable-name-face . "<I>")
;    (font-lock-reference-face . "<I>")
;    (font-lock-keyword-face . "<B><EM>")
;    (font-lock-type-face . "<EM>")
;    (default . ""))
;  "Association List for buffer2xhtml (nocolor): font . HTML Tag to start")

;(defvar b2h-end-nocolor
;  '((font-lock-comment-face . "</I>")
;    (font-lock-preprocessor-face . "</I>")
;    (font-lock-string-face . "</I>")
;    (font-lock-doc-string-face ."</I>")
;    (font-lock-function-name-face . "</STRONG><A NAME=\"%s\">")
;;;    (font-lock-function-name-face . "</STRONG>")
;    (font-lock-variable-name-face . "</I>")
;    (font-lock-reference-face . "</I>")
;    (font-lock-keyword-face . "</B></EM>")
;    (font-lock-type-face . "</EM>")
;    (default . ""))
;  "Association List for buffer2xhtml (nocolor): font . HTML Tag to end
;use %s to get text of the fontified region")

(defun b2h-trim (string)
  "trim a STRING: replace all ' ' by '' "
  (replace-in-string string " " ""))

(defun buffer2xhtml ()
  "convert current buffer to html
 Howto convert a file to html:
 1) open a file, fontify
 2) M-x buffer2xhtml
    this will change the buffers name to oldname.html and
    add all the HTML Tags
 3) save buffer
 4) view with your favorite browser"
  (interactive)
  (if (buffer-modified-p)
      (message "Please save buffer before using buffer2xhtml !!")
      (let (pos 
            old-prop
            startpos 
            func-list
            (name (buffer-name)) 
            (file-name (buffer-file-name (current-buffer)))
            (b2h-start b2h-start-color) 
            (full-page (y-or-n-p "Make full page ")))
        ;; change buffer name 
        (set-visited-file-name (concat name ".html" ))
        (find-file file-name)
        (switch-to-buffer (concat name ".html"))
        
        ;; stop (auto-)fontifying on changes
        (remove-hook 'after-change-functions 'font-lock-after-chanxbge-function t)
        (remove-hook 'pre-idle-hook 'font-lock-pre-idle-hook t)
        ;; replace <, >, & with html version
        (goto-char (point-min))
        (replace-string "&" "&amp;")
        (goto-char (point-min))
        (replace-string "<" "&lt;")
        (goto-char (point-min))
        (replace-string ">" "&gt;")
        ;(message "Inserting HTML Tags ...")

        ;; loop for all face changes
        (goto-char (point-min))
        (insert "\n")
        (put-nonduplicable-text-property (point-min) (point) 'face nil)
        (backward-char)
        (while (not (eobp))
          (let ((next-change (or (next-property-change (point) (current-buffer))
                                 (point-max))))
            ;; Process text from point to NEXT-CHANGE...
            (goto-char next-change)
            ;(insert (format "(%s %s)" old-prop (get-text-property next-change 'face)))
            (if (not (eq old-prop (get-text-property next-change 'face)))
                (progn
                  (if old-prop (insert "</span>"))
                  ;; get new face
                  (setq old-prop (get-text-property next-change 'face))
                  ;; start new HTML-tag
                  (if old-prop
                      (let ((v '(assoc old-prop b2h-start)))
                        (if (not (eval v))
                            (progn
                              (add-to-list 'b2h-start 
                                           `(,old-prop .
                                                       ,(format "<span class=\"%s\">" 
                                                                (symbol-name old-prop))))
                              (add-to-list 
                               'b2h-rgb-color
                               `(,old-prop 
                                 . (face-to-style-str ',old-prop ,(symbol-name old-prop))))))
                        (insert (cdr (eval v)))))
                  ))
            ))

        ;; insert header
        (goto-char (point-min))
        (if full-page
            (insert "<html><head><title> Source: " name " </title>\n"))
        (insert "<style>\n")
        (mapc (lambda (x) (insert (eval (cdr (assoc (car x) b2h-rgb-color))))) b2h-start)
        (insert "</style>\n\n")
        (if full-page 
            (insert "</head><body>"
                    "<h1> " name " </h1>\n" 
                    "<!-- created by buffer2xhtml.el -->\n"
                    "\n\n<pre>"))
        (goto-char (point-max))
        (if full-page (insert "\n</pre></body></html>\n"))
        ;; add-functions
        ;(goto-char (point-min))
        ;(forward-line 4)
                                        ;(if ins-func-list
                                        ;(while func-list
                                        ; (let ((name (car func-list)))
                                        ;  (insert (format "<a href=\"#%s\">%s</a>\n" (b2h-trim name) name))
                                        ; (setq func-list (cdr-safe func-list)))))
                                        ;(insert "<hr>\n")
        (message "done"))))


(provide 'buffer2xhtml)
