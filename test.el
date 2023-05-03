(require 'ert)
(load-file "ox-html-markdown-style-footnotes.el")

(ert-deftest footnote-test ()
  (org-html-markdown-style-footnotes-add)
  (find-file "test/fixtures/footnote.org")
  (let ((org-html-stable-ids t))
    (org-html-export-as-html))
  (should (string-match-p
	   "<ol>\n<li class=\"footdef\" id=\"fn.1\"><div class=\"footpara\" role=\"doc-footnote\"><p class=\"footpara\">\nA footnote.\n</p></div><a href=\"#fnr.1\" role=\"doc-backlink\">↩&#65038;</a></li>\n</ol>"
	   (with-current-buffer "*Org HTML Export*" (buffer-string))))
  (org-html-markdown-style-footnotes-add))
