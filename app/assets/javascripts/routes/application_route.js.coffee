Theoj.ApplicationRoute = Ember.Route.extend
  model :->
    Theoj.User.current_user()
