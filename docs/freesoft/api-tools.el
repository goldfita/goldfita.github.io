;; api-tools.el --- For API creation/discovery

;; This is provided under the GPL 2.0.

;; Author: 2006 Todd Goldfinger
;; Maintainer: 
;; Created:    May 2006

;; Commentary:

;; This is a collection of functions for building and discovering APIs.
;; Implemented functions are
;;
;; find-header:
;;   Searches for a prototype in the include files from the function
;;   name.  You must place the following on a single comment line
;;   somewhere in your source file.  Note there is no slash at the end
;;   of the directory.
;;
;;   $Headers: "/src/to/include/directory"
;;
;;   In some cases, you will get something other than the prototype if
;;   code has been put in the header file.  There is only so much a
;;   regexp can do...  Also, directories are not searched recursively.
;;   This will not work if there are subdirectories.  This is meant to
;;   work with C, but it will probably work with Java as well.
;;
;; find-source:
;;   Searches for the complete definition of a function.  It works
;;   basically the same as find-header, but you need to give it the
;;   directory of the full source code.
;;
;;   $Source:  "/usr/src/ruby-1.8.4"
;;
;; make-proto:
;;   Searches through a C file and inserts prototypes of the
;;   functions.  The declaration of the functions needs to be on a
;;   single line.  You need to put the following in a comment before
;;   the functions.
;;
;;   $Prototypes:
;;
;;
;;
;; Todo:
;;   -Add recursive directory reads.
;;   -Allow lookups to work with scripting languages (Python, Ruby, ...).



(defun nop() (lambda(): nil))
(defvar file-prototypes
  '((default . ""))
  "Association List for function prototypes")
(defvar file-functions
  '((default . ""))
  "Association List for functions")

(setq header-params
      '((name . nil)
        (type . " *$Headers: *\"")
        (file . ".+?[.]hp*$")
        (finder . find-proto)
        (alst . file-prototypes)))

(setq source-params 
      '((name . nil)
        (type . " *$Source: *\"")
        (file . ".+?[.]cp*$")
        (finder . find-func-if-def)
        (alst . file-functions)))


(defun text-from (start end)
  (buffer-substring start end))

(defun lib-dir (tag)
  (let ((end (point))
        (eb  (eobp)))
    (if (not eb)
        (forward-line -1)
      (if (and eb (eq end (progn (forward-line 0) (point))))
          (forward-line -1)))
    (if (re-search-forward tag end (nop) 1)
        (let ((dstart (point)))
          (if (search-forward "\"" end (nop) 1)
              (buffer-substring dstart (- (point) 1)))))))

(defun find-lib-dir (tag)
  (save-excursion
    (goto-char (point-min))
    (find-it tag nil 'lib-dir)))

(defun find-it (tag it func)
  (if it it
    (progn
      (while (and (not (eobp)) (not (forward-comment)))
        (goto-char (+ 1 (point))))
      (if (not (eobp))
          (find-it tag (eval `(,func tag)) func)
        (eval `(,func tag))))))

(defun is-tag (tag)
  (progn 
    (forward-line -1)
    (if (re-search-forward tag (point-max) (nop) 1) t)))

;; This should be made recursive.  Multiple directories will not work.
(defun find-in-dir (params)
  (let ((text (assoc 
                (cdr (assoc 'name params))
                (eval (cdr (assoc 'alst params))))))
    (if text
        (cdr text)
      (let* ((dir-name (find-lib-dir (cdr (assoc 'type params))))
             (d-buf (find-file-noselect dir-name))
             (text nil))
        (switch-to-buffer d-buf)
        (goto-char (point-min))
        (while (and
                (not (eobp))
                (not text)
                (re-search-forward (cdr (assoc 'file params)) (point-max) (nop) 1))
          (let* ((f-name (let ((end (point))
                               (start (progn (search-backward " ") (+ 1 (point)))))
                           (buffer-substring start end)))
                 (abs-file (concat dir-name "/" f-name)))
            (setq text (find-in-file! abs-file params))
            (if (not (eobp)) (forward-line 1))))
        (kill-buffer d-buf)
        text))))

(defun find-proto (func-name)
  (if (re-search-forward (concat "[a-zA-Z_0-9* \n\r\t]+" func-name 
                                 " *([][ *a-zA-Z0-9_.()]+?) *;[ \t]*$") (buffer-size) (nop) 1)
      (progn 
        (forward-line 0)
        (let ((start (point)))
          (end-of-line)
          (buffer-substring start (point))))))

(defun find-in-file! (f params)
  (let ((text (assoc 
               (cdr (assoc 'name params))
               (eval (cdr (assoc 'alst params))))))
    (if text
        text
      (let ((f-buf (find-file-noselect f))
            (flaf nil))
        (if (or font-lock-auto-fontify font-lock-mode)
            (progn
              (setq font-lock-auto-fontify nil)
              (setq font-lock-mode nil)
              (setq flaf t)))
        (switch-to-buffer f-buf)
        (let ((text (eval (list (cdr (assoc 'finder params)) (cdr (assoc 'name params))))))
          ;(if flaf 
          ;    (progn
          ;      (setq font-lock-auto-fontify t)
          ;      (setq font-lock-mode t)))
          (kill-buffer f-buf)
          (if text (add-to-list 
                    (cdr (assoc 'alst params))
                    `(,(eval (cdr (assoc 'name params))) . ,text)))
          text)))))


(defun find-header ()
  (interactive)
  (find-text header-params 'message))

(defun find-source ()
  (interactive)
  (find-text source-params 
             '(lambda (text)
                (if text
                    (progn
                      (switch-to-buffer-other-window "function")
                      (insert text)
                      (goto-char (point-min))
                      (message "Found"))
                  (message "Not Found")))))

(defun find-text (params disp)
  (save-excursion 
    (let ((start nil)
          (end nil))
;^%!~<>=;:,|
      (re-search-backward "[ \r\n\t({\"+-/*]" (- (point-max)) (nop) 1)
      (setq start (+ (point) 1))
      (goto-char start)
      (re-search-forward "[ \r\n\t)}\"+-/*]" (point-max) (nop) 1)
      (setq end (- (point) 1))
      (eval `(,disp
              (find-in-dir
               (setq params 
                     (cons `(name . ,(buffer-substring start end)) (cdr params)))))))))

(defun find-func-if-def (func-name)
  (if
      (re-search-forward (concat "^[a-zA-Z_0-9* \n\r\t]+" 
                                 func-name " *([][ *a-zA-Z0-9_.()]+?)[^{]*") (point-max) (nop) 1)
      (let ((start nil)
            (end nil)
            (text nil))
        (search-backward "(" (- (point-max)) (nop) 1) ;get past any semicolons
        (re-search-backward "[};]" (- (point-max)) (nop) 1)
        (goto-char (+ (point) 1))
        (re-search-forward "[^ \nr\t]" (point-max) (nop) 1)
        (goto-char (- (point) 1))
        (setq start (point))
        (if (is-func func-name)
            (progn
              (setq end (point))
              (setq text (buffer-substring start end))
              text)
          nil))
    nil))

;count semicolons
(defun is-func (func-name)
  (let ((brace 1)
        (last t)
        (start (point))
        (end nil))
    (search-forward "{" (point-max) (nop) 1)
    (setq end (point))
    (goto-char start)
    (if (search-forward func-name end (nop) 1)
        (progn
          (goto-char end)
          (while (and (not (equal brace 0)) last)
            (progn
              (setq last (re-search-forward "[{}]" (point-max) (nop) 1))
              (if (equal (buffer-substring (- (point) 0) (- (point) 1)) "{")
                  (setq brace (+ 1 brace))
                (setq brace (- brace 1)))))
          (and 
           (equal (buffer-substring (- (point) 1) (- (point) 2)) "\n")
           (equal brace 0))))))

(defun make-protos ()
  (interactive)
  (save-excursion
    (setq kill-ring '())
    (setq kill-ring-yank-pointer '())
    (let ((cnt -1)
          (protos '()))
      (while (copy-next-proto) 
        (setq cnt (+ 1 cnt)))
      (goto-char (point-min))
      (if (find-it " *$Prototypes: *" nil 'is-tag)
          (let ((start (point))
                (end nil))
                                        ;add old prototypes to list
            (if (find-it " *:sepytotorP$ *" nil 'is-tag)
                (progn
                  (forward-line -1)
                  (setq end (point))
                  (goto-char start)
                  (while (< (point) end)
                    (progn
                      (forward-line)
                      (mark-end-of-line 1)
                      (copy-primary-selection)
                      (setq protos (append protos (list (car kill-ring))))))))
            (goto-char start)
            (forward-line)
            (while (> cnt -1)
              (let ((elm (format "%s;" (nth (+ (length protos) cnt)  kill-ring))))
                (if (not (member elm protos))
                    (insert (format "%s\n" elm)))
                (setq cnt (- cnt 1))))
            (if (eq (length protos) 0)
                (progn
                  (insert " :sepytotorP$\n")
                  (forward-line -1)
                (comment-region (point) (+ 14 (point))))))))))
  
  
(defun copy-next-proto ()
    (if (and
         (re-search-forward "^[a-zA-Z_0-9* \t]+[a-zA-Z0-9_]* *([][ *a-zA-Z0-9_.()]+?)[^{]*" (point-max) (nop) 1)
         (not (eobp)))
        (let ()
          (search-backward "(" (- (point-max)) (nop) 1)
          (forward-line 0)
          (mark-end-of-line 1)
          (copy-primary-selection)
          (forward-line 1)
          t)))

(provide 'api-tools)





