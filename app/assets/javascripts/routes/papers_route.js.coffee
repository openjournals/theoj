


Theoj.PapersRoute = Ember.Route.extend
  allowed_types : ["submitted", "in_review", "accepted"]

  beforeModel: (transition)->
    console.log transition
    if @get("allowed_types").indexOf(transition.params.papers.type) == -1
      @transitionTo('/')

  model:(params)->
    papers = Theoj.Paper.get_type(params.type)
    @set "type", params.type
    papers

  active:->
    @set "controller.paperType",params.type

  setupController:(controller)->
    controller.set("paperType", @get("type"))


Theoj.PaperRoute = Ember.Route.extend
  model :(params)->
    Theoj.Paper.get(params.id)


Theoj.SubmitPaperRoute = Ember.Route.extend
  model:(params)->
    Theoj.Paper.create
      title : "New Paper"
