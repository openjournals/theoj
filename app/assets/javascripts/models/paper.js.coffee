Theoj.Paper = Ember.Object.extend()

Theoj.Paper.reopenClass
  asReviwer : (user)=>
    $.getJSON "/papers/as_reviewer", (papers)->
      results = (@create(paper) for paper in papers)

  asEditor : (user) =>
    $.getJSON "/papers/as_editor", (papers)->
      results = (@create(paper) for paper in papers)

  asAuthor : (user)=>
    $.getJSON "/papers/as_author", (papers)->
      results = (Theoj.Paper.create(paper) for paper in papers.papers)
      Em.A(results)

  accepted: (user)=>
    $.getJSON "/papers/accepted", (papers)->
      results = (@create(paper) for paper in papers)

  get :(paper_id)=>
    $.getJSON "/papers/#{paper_id}", (result)->
      window.raw_res = result
      Theoj.Paper.create(result.paper.paper)
