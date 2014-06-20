
Theoj.PaperControlsComponent = Ember.Component.extend
  user: null
  paper: null
  paperIsPending:  Ember.computed.equal('paper.state', 'pending')
  paperIsUnderReview:  Ember.computed.equal('paper.state', 'under_review')
  paperIsAccepted:  Ember.computed.equal('paper.state', 'accepted')
  showReviewerInfo: Ember.computed.or("user.editor", "user.admin")

  actions :
    assignReviewer: ->
      alert("assigning reviwer")
