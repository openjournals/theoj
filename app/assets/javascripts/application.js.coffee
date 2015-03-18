#= require jquery
#= require marked.min
#= require markdown_stripper
#  pdf-worker must come before pdf.js
#= require pdfjs-dist/build/pdf.worker
#= require pdfjs-dist/build/pdf
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
      inlineMath:  [['$','$']],
      displayMath: [['$$','$$']]
  )



