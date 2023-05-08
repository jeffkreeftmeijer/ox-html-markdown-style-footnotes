;;; ox-html-markdown-style-footnotes.el --- Markdown-style footnotes for ox-html.el

;;; Commentary:

;; ox-html-markdown-style-footnotes replaces the ox-html's default
;; footnotes with an HTML ordered list, inspired by footnotes sections
;; of some Markdown implementations.

;;; Code:

(require 'ox-html)

(defun org-html-markdown-style-footnotes--section (orig-fun &rest args)
  "Replace ORIG-FUN with a Markdown-style footnotes section.
        ARGS contains the info plist, which is used as a communication channel."
  (let ((info (car args)))
    (pcase (org-export-collect-footnote-definitions info)
      (`nil nil)
      (definitions
       (format "<hr>\n<ol>\n%s</ol>\n"
               (mapconcat
                (lambda (definition)
                  (pcase definition
                    (`(,n ,_ ,def)
                     (format
                      "<li class=\"footdef\" id=\"fn.%d\">%s%s</li>\n"
                      n
                      (format "<div class=\"footpara\" role=\"doc-footnote\">%s</div>" (org-trim (org-export-data def info)))
                      (format "<a href=\"#fnr.%d\" role=\"doc-backlink\">↩&#65038;</a>" n)))))
                definitions
                "\n"))))))

;;;###autoload
(defun org-html-markdown-style-footnotes-add ()
  (interactive)
  (advice-add 'org-html-footnote-section
              :around #'org-html-markdown-style-footnotes--section))

(defun org-html-markdown-style-footnotes-remove ()
  (interactive)
  (advice-remove 'org-html-footnote-section
                 #'org-html-markdown-style-footnotes--section))

(provide 'ox-html-markdown-style-footnotes)

;;; ox-html-markdown-style-footnotes.el ends here
