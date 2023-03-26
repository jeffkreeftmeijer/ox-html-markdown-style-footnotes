(require 'ox-html)

(defun ox-html-markdown-style-footnotes--section (orig-fun &rest args)
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
                      (format "<a href=\"#fnr.%d\" role=\"doc-backlink\">↩</a>" n)))))
                definitions
                "\n"))))))

(advice-add 'org-html-footnote-section
            :around #'ox-html-markdown-style-footnotes--section)
