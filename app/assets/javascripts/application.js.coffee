#= require jquery
#= require_self
#= require marked

$(document).ready ->
  MathJax.Hub.Config({messageStyle: 'none', showMathMenu: false, tex2jax: {preview: 'none', inlineMath: [['$','$']], displayMath: [['$$','$$']]}});
