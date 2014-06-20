Theoj.User = Ember.Object.extend()

Theoj.User.reopenClass
  current_user: ->
    ajax.request("/current_user/").then (user_data)->
      if user_data
        Theoj.User.create user_data
      else
        null
