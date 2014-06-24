Theoj.PaperController = Ember.ObjectController.extend
  needs: ["application"]
  user : Em.computed.alias "controllers.application.model"
