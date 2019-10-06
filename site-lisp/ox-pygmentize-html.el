;;; ox-pygmentize-html --- org-mode to html export with code highlight -*- lexical-binding:t -*-
;;; Commentary:
;;; code written by Warashi
;;; Code:

(require 'org)
(require 'ox)
(require 'ox-html)

;; Path for pygments or command name
(defcustom org-pygments-path "pygmentize"
  "Path of the pygmentize command."
  :type 'string)

(defcustom org-pygments-option '()
  "Option of pygmentize (-O).
This list is concatenated with `,' as separator."
  :type '(string))

;;;###autoload
(defun ox-pygments-org-html-code (code contents info)
  "Export to html function with pygments code highlight."
  (let ((pygments-language (or (org-element-property :language code) ""))
        (pygments-option (mapconcat #'identity org-pygments-option ",")))
    (with-temp-buffer
      (insert (org-element-property :value code))
      (print pygments-option)
      (apply #'call-process-region
             `(,(point-min) ,(point-max)
               ,org-pygments-path
               t t nil
               "-l" ,pygments-language
               "-f" "html"
               "-O" ,pygments-option))
      (buffer-string))))

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
    (example-block . ox-pygments-org-html-code))
  :filters-alist '((:filter-final-output . nil)))

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
