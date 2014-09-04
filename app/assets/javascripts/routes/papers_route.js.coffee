
Theoj.PapersRoute = Ember.Route.extend
  allowed_types : ["submitted", "in_review", "accepted"]

  beforeModel: (transition)->
    if @get("allowed_types").indexOf(transition.params.papers.type) == -1
      @transitionTo('/')

  model:(params)->
    papers = Theoj.Paper.getType(params.type)
    @set "type", params.type
    papers

  active:->
    @set "controller.paperType",params.type

  setupController:(controller)->
    controller.set("paperType", @get("type"))


Theoj.PaperRoute = Ember.Route.extend
  model :(params)->
    Theoj.Paper.get(params.paper_id)

Theoj.SubmitPaperRoute = Ember.Route.extend
  model:(params)->
    Theoj.Paper.create
      title : "New Paper"

Theoj.PaperReviewRoute = Ember.Route.extend
  # renderTemplate: ->
  #   @render
  #     outlet: 'root'

  model:(params)->
    paperRequest = Theoj.Paper.get(params.paper_id)

    paperRequest.catch ->
      console.log "failed to get paper "
      @transitionTo('/')

    paperRequest
