Theoj.IndexRoute = Ember.Route.extend
  model: ->
    Theoj.Paper.recent()
