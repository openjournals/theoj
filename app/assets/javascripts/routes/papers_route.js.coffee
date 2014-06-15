Theoj.PapersAssignmentRoute = Ember.Route.extend
  model : ->
    Theoj.Paper.asEditor()

Theoj.PapersReviewRoute = Ember.Route.extend
  model : ->
    Thoj.Paper.asReviewer()

Theoj.PapersSubmittedRoute = Ember.Route.extend
  model : ->
    Theoj.Paper.asAuthor()

Theoj.PapersIndexRoute   = Ember.Route.extend
  model : (params) ->
    Theoj.Paper.get(params.id)
