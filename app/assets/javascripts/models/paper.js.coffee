Theoj.Paper = Ember.Object.extend
  submit: ->
    $.post '/papers', {paper: @serialize()}

  serialize:->
    {title : @title, location: @location}

Theoj.Paper.reopenClass

  get_type: (type)=>
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

  assignReviewer: (username) =>
