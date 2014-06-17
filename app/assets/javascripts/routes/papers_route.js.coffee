Theoj.PapersAssignmentRoute = Ember.Route.extend
  model : ->
    Theoj.Paper.asEditor()

Theoj.PapersReviewRoute = Ember.Route.extend
  model : ->
    Thoj.Paper.asReviewer()

Theoj.PapersSubmittedRoute = Ember.Route.extend
  controllerName: "paper_list"

  model:->
    Theoj.Paper.asAuthor()

  setupController:(controller)->
    controller.set("paperType", "Submitted")

  renderTemplate: ->
    @render('papers/papers_list')


Theoj.PaperRoute = Ember.Route.extend
  model :(params)->
    Theoj.Paper.get(params.id)
