;;; ivy-exwm.el --- Ivy completion for EXWM. -*- lexical-binding: t -*-

;; Copyright (C) 2018 Peter Jones <pjones@devalot.com>

;; Author: Peter Jones <pjones@devalot.com>
;; Homepage: https://github.com/pjones/exwm-nw
;; Package-Requires: ((emacs "25.1") (exwm "0.18") (ivy "0.10") (ivy-rich "0.0"))
;; Version: 0.1.0
;;
;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; Connect Ivy and EXWM:
;;
;; Enable `ivy-exwm-mode' to:
;;
;;   * Show EXWM window titles and class names in `ivy-switch-buffer'

;;; License:
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;; Code:
(require 'exwm)
(require 'ivy)
(require 'ivy-rich)

(defvar ivy-exwm-orig-switch-buffer-transformer nil)
(defvar ivy-exwm-pad-function (if (fboundp 'ivy-rich-pad)
                                  'ivy-rich-pad
                                'ivy-rich-switch-buffer-pad))

(defun ivy-exwm--format (str len &optional face)
  "Format STR by padding it to LEN.

When FACE is non-nil, propertize STR."
  (let ((padded (apply ivy-exwm-pad-function str len nil)))
    (if face (propertize padded 'face face)
      padded)))

;;;###autoload
(defun ivy-exwm-switch-buffer-transformer (candidate)
  "Ivy candidate transformer for `ivy-switch-buffer'.

If CANDIDATE is an EXWM buffer, display it buffer name and window
title, otherwise pass the candidate off to
`ivy-rich-switch-buffer-transformer'."
  (let ((buf (get-buffer candidate)))
    (if (and buf (with-current-buffer buf (derived-mode-p 'exwm-mode)))
        (with-current-buffer buf
          (ivy-rich-switch-buffer-format
           (list (ivy-exwm--format candidate ivy-rich-switch-buffer-name-max-length)
                 (ivy-exwm--format (concat exwm-title " ") ivy-rich-switch-buffer-name-max-length 'ivy-virtual)
                 (ivy-exwm--format (concat exwm-class-name " ") ivy-rich-switch-buffer-mode-max-length 'success))))
      (ivy-rich-switch-buffer-transformer candidate))))

;;;###autoload
(define-minor-mode ivy-exwm-mode
  "Toggle ivy-exwm-mode globally."
  :global t
  (if ivy-exwm-mode
      (progn
        (setq ivy-exwm-orig-switch-buffer-transformer (plist-get ivy--display-transformers-list 'ivy-switch-buffer) )
        (ivy-set-display-transformer 'ivy-switch-buffer 'ivy-exwm-switch-buffer-transformer))
    (ivy-set-display-transformer 'ivy-switch-buffer ivy-exwm-orig-switch-buffer-transformer)))

(provide 'ivy-exwm)
;;; ivy-exwm.el ends here
