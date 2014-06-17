Theoj.SubmitPaperController = Ember.ObjectController.extend
  errors : []

  actions:
    submit: (data)->
      paper = @get("model")
      request = paper.submit()

      request.then (result)=>
        console.log result
        @transitionToRoute 'paper', result.paper.sha

      request.error (result)=>
        @set 'errors', result.paper
        alert("error")
