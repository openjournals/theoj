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

Theoj.Paper.reopenClass

  getType: (type)=>
    ajax.request("/papers/#{type}").then (papers)->
      results = (Theoj.Paper.create(paper) for paper in papers.papers)
      Em.A(results)

  recent: =>
    ajax.request("/papers").then (papers)->
      results = (Theoj.Paper.create(paper) for paper in papers.papers)
      Em.A(results)

  get :(paper_id)=>
    ajax.request("/papers/#{paper_id}").then (result)->
      Theoj.Paper.create(result.paper)
