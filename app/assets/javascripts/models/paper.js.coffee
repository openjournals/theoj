Theoj.Paper = Ember.Object.extend

  submit: ->
    $.post '/papers', {paper: @serialize()}

  serialize:->
    {title : @title, location: @location}

  assignReviewer: (username) ->
    ajax.request
      url: "/papers/#{@sha}/assign_reviewer"
      type: "POST"
      data:
        user_name: username

  removeReviewer: (username)->
    ajax.request
      url: "/papers/#{@sha}/remove_reviewer"
      type: "POST"
      data:
        user_name: username

  fetchAnnotations:->
    ajax.request("/papers/#{@sha}/annotations").then (annotations)->
      result = for annotation in annotations
        Theoj.annotaions.create(annotation)
      Em.A result



Theoj.Paper.reopenClass

  getType: (type)=>
    request = ajax.request("/papers/#{type}")
    request.then (papers)->
      results = (Theoj.Paper.create(paper) for paper in papers)
      Em.A(results)
    request.catch (error)->
      Em.A([])

  recent: =>
    request = ajax.request("/papers")
    request.then (papers)->
      results = (Theoj.Paper.create(paper) for paper in papers)
      Em.A(results)
    request.catch (error)->
      Em.A([])

  get :(paper_id)=>
    request = ajax.request("/papers/#{paper_id}")

    request.catch (error)->
      null

    request.then (result)->
      Theoj.Paper.create(result)
