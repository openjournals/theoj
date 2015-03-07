#= require jquery
#= require marked.min

#= require_self

$(document).ready ->
  MathJax.Hub.Config(
    messageStyle: 'none',
    showMathMenu: false
    tex2jax:
      preview:     'none',
      inlineMath:  [['$','$']],
      displayMath: [['$$','$$']]  )
