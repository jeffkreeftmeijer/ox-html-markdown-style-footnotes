
# Export Org documents with Markdown-style footnotes

```org
Hello, world![fn:1]
[fn:1] A footnote.
```

The Org document above produces the following footnotes when exported to HTML:

```html
<div class="footdef"><sup><a id="fn.1" class="footnum" href="#fnr.1" role="doc-backlink">1</a></sup> <div class="footpara" role="doc-footnote"><p class="footpara">
A footnote.
</p></div></div>
```

Footnotes consist of a link back to the place the footnote was referenced in the document and a `<div>` with the footnote's contents. The contents div, being a block element, is printed on a seperate line unless the default styling is loaded. The styling makes the footnotes appear inline, which places them behing the footnote link, but also inlines each paragraph for multi-paragraph footnotes:

```org
Hello, world![fn:1]
[fn:1] A footnote.

With a second paragraph.
```

```html
<div class="footdef"><sup><a id="fn.1" class="footnum" href="#fnr.1" role="doc-backlink">1</a></sup> <div class="footpara" role="doc-footnote"><p class="footpara">
A footnote.
</p>

<p class="footpara">
With a second paragraph.
</p></div></div>
```

Some flavors of Markdown use [ordered lists for footnotes](https://www.markdownguide.org/extended-syntax/#footnotes). These don't rely on styling, and they don't inline paragraphs in the footnotes.

To use Markdown-style footnotes in Org, advise the `org-html-footnote-section` function.<sup><a id="fnr.1" class="footref" href="#fn.1" role="doc-backlink">1</a></sup> This new function keeps most of the output the same, but uses an ordered list instead of nested `<div>` elements. It also uses a backlink with an arrow, which resembles the Markdown tradition:

```emacs-lisp
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
```

After adding the advise with `org-html-markdown-style-footnotes-add`, the exported footnotes are Markdown-style unordered lists:

```html
<hr>
<ol>
<li class="footdef" id="fn.1"><div class="footpara" role="doc-footnote"><p class="footpara">
A footnote.
</p>

<p class="footpara">
With a second paragraph.
</p></div><a href="#fnr.1" role="doc-backlink">↩</a></li>
</ol>
```

## Footnotes

<sup><a id="fn.1" class="footnum" href="#fnr.1">1</a></sup> [Currently](https://git.savannah.gnu.org/cgit/emacs/org-mode.git/tree/lisp/ox-html.el?h=44e1cbb09484c8f8c49ef49376ef7988b04decc2#n1857), the `org-html-footnote-section` function looks like this:

```emacs-lisp
(defun org-html-footnote-section (info)
  "Format the footnote section.
INFO is a plist used as a communication channel."
  (pcase (org-export-collect-footnote-definitions info)
    (`nil nil)
    (definitions
     (format
      (plist-get info :html-footnotes-section)
      (org-html--translate "Footnotes" info)
      (format
       "\n%s\n"
       (mapconcat
	(lambda (definition)
	  (pcase definition
	    (`(,n ,_ ,def)
	     ;; `org-export-collect-footnote-definitions' can return
	     ;; two kinds of footnote definitions: inline and blocks.
	     ;; Since this should not make any difference in the HTML
	     ;; output, we wrap the inline definitions within
	     ;; a "footpara" class paragraph.
	     (let ((inline? (not (org-element-map def org-element-all-elements
				   #'identity nil t)))
		   (anchor (org-html--anchor
			    (format "fn.%d" n)
			    n
			    (format " class=\"footnum\" href=\"#fnr.%d\" role=\"doc-backlink\"" n)
			    info))
		   (contents (org-trim (org-export-data def info))))
	       (format "<div class=\"footdef\">%s %s</div>\n"
		       (format (plist-get info :html-footnote-format) anchor)
		       (format "<div class=\"footpara\" role=\"doc-footnote\">%s</div>"
			       (if (not inline?) contents
				 (format "<p class=\"footpara\">%s</p>"
					 contents))))))))
	definitions
	"\n"))))))
```