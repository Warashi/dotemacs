;;; ox-pygmentize-html --- org-mode to html export with code highlight
;;; Commentary:
;;; code mainly taken from https://linevi.ch/en/org-pygments.html
;;; Code:

(require 'org)
(require 'ox)
(require 'ox-html)

;; Path for pygments or command name
(defcustom ox-pygments-path "pygmentize"
  "Path of the pygmentize command."
  :type 'string)

;;;###autoload
(defun ox-pygments-org-html-code (code contents info)
  "export to html function with pygments code highlight."
  (let ((temp-source-file (format "/tmp/pygmentize-%s.txt" (md5 (current-time-string)))))
    (with-temp-file temp-source-file (insert (org-element-property :value code)))
    (shell-command-to-string (format "%s -l \"%s\" -f html %s"
                                     ox-pygments-path
                                     (or (org-element-property :language code) "")
                                     temp-source-file))))

(org-export-define-derived-backend 'html-with-pygmentize 'html
  :menu-entry
  '(?H "Export to HTML with pygments code highlight"
       ((?H "As HTML buffer" org-html-export-as-html-with-pygmentize)
        (?h "As HTML file" org-html-export-to-html-with-pygmentize)
        (?o "As HTML file and open"
            (lambda (a s v b)
              (if a (org-html-export-to-html-with-pygmentize)
                (org-open-file (org-html-export-to-html-with-pygmentize nil s v b)))))))
  :translate-alist
  '((src-block .  ox-pygments-org-html-code)
    (example-block . ox-pygments-org-html-code)))

;;;###autoload
(defun org-html-export-as-html-with-pygmentize (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (org-export-to-buffer 'html-with-pygmentize "*Org HTML with Pygmentize Export*"
    async subtreep visible-only body-only ext-plist (lambda () (html-mode))))

;;;###autoload
(defun org-html-export-to-html-with-pygmentize (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let ((outfile (org-export-output-file-name ".html" subtreep)))
    (org-export-to-file 'html-with-pygmentize outfile
      async subtreep visible-only body-only ext-plist)))

(provide 'ox-pygmentize-html)
;;; ox-pygmentize-html.el ends here

;;; Local Variables:
;;; lexical-binding: t
;;; End:
