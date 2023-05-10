;;; ox-html-markdown-style-footnotes.el --- Markdown-style footnotes for ox-html.el

;;; Commentary:

;; ox-html-markdown-style-footnotes replaces the ox-html's default
;; footnotes with an HTML ordered list, inspired by footnotes sections
;; of some Markdown implementations.

;;; Code:

(require 'ox-html)

(defun org-html-markdown-style-footnotes--section (info)
  (pcase (org-export-collect-footnote-definitions info)
    (`nil nil)
    (definitions
     (format
      (plist-get info :html-footnotes-section)
      (org-html--translate "Footnotes" info)
      (format
       "<ol>\n%s</ol>\n"
       (mapconcat
        (lambda (definition)
          (pcase definition
            (`(,n ,_ ,def)
             (format
              "<li class=\"footdef\" role=\"doc-footnote\">%s %s</li>\n"
              (org-trim (org-export-data def info))
              (org-html--anchor
               (format "fn.%d" n)
               "↩&#65038;"
               (format " href=\"#fnr.%d\" role=\"doc-backlink\"" n)
               info)))))
        definitions
        "\n"))))))

  ;;;###autoload
(defun org-html-markdown-style-footnotes-add ()
  (interactive)
  (advice-add 'org-html-footnote-section
              :override #'org-html-markdown-style-footnotes--section))

(defun org-html-markdown-style-footnotes-remove ()
  (interactive)
  (advice-remove 'org-html-footnote-section
                 #'org-html-markdown-style-footnotes--section))

(provide 'ox-html-markdown-style-footnotes)

;;; ox-html-markdown-style-footnotes.el ends here
