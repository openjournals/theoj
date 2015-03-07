#= require jquery
#= require marked.min

#= require_self

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



