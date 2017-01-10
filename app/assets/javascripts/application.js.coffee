#= require jquery
#= require webcomponentsjs/webcomponents-lite
#= require pushstate-anchor
#= require marked.min
#= stub    pdfjs-dist/build/pdf.worker
#= stub    pdf.worker
#= stub    bootstrap
#= stub    textlayerbuilder
#= require pdfjs-dist/build/pdf
#= require_self
#= require_tree .

window.Oj = {}

Oj.app = ->
  document.querySelector('oj-app');
