Theoj.Paper = Ember.Object.extend()

Theoj.Paper.reopenClass
  asReviwer : (user)=>
    $.getJSON "/#{user.id}/papers/as_reviewer", (papers)->
      results = (@create(paper) for paper in papers)

  asEditor : =>
    $.getJSON "/#{user.id}/papers/as_editor", (papers)->
      results = (@create(paper) for paper in papers)

  asAuthor :=>
    $.getJSON "/#{user.id}/papers/as_author", (papers)->
      results = (@create(paper) for paper in papers)

  accepted:=>
    $.getJSON "/papers/accepted", (papers)->
      results = (@create(paper) for paper in papers)

  get :(paper_id)=>
    $.getJSON '/papers/'
