Ember.Handlebars.helper 'paper-image', (paper, options)->
  lookup =
    "accepted"  : "accepted"
    "pending"   : "submit"
    "in_review" : "view"
  new Ember.Handlebars.SafeString  "<img  class='paper_icon' src='/assets/paper_#{lookup[paper.state]}.png' />"
