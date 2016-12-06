#= require jquery
#= require webcomponentsjs/webcomponents-lite
#= require pushstate-anchor
#= require marked.min
#= stub    pdfjs-dist/build/pdf.worker
#= stub    pdf.worker
#= stub    bootstrap
#= stub    textlayerbuilder
#= require pdfjs-dist/build/pdf
#= require_tree .

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
      inlineMath:  [['$','$']],
      displayMath: [['$$','$$']]
  )



