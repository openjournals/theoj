###################################################
## Initialize 3rd-Party libraries
##

PDFJS.workerSrc = '/assets/pdf.worker.js'

$ ->

  marked.setOptions(
    gfm:      true,
    breaks:   true,
    sanitize: true
  )

  MathJax.Hub.Config(
    messageStyle: 'none',
    showMathMenu: false
    tex2jax:
      preview:     'none',
      inlineMath:  [ ['$','$'],   ["\\(","\\)"] ],
      displayMath: [ ['$$','$$'], ["\\[","\\]"] ]
  )

  MathJax.typeset = (element) ->
      element = element.node || element;  # Handle Polymer wrapped nodes
      MathJax.Hub.Queue(
        ['Typeset', MathJax.Hub, element ]
      );

