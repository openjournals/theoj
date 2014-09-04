Theoj.IssueComponent = Ember.Component.extend
  showConversation: false
  comments: Em.computed.length("model.comments")

  actions:
    toggleConversation:->
      @toggle("showConversation")
