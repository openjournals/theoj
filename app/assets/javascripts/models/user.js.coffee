Theoj.User = Ember.Object.extend()

Theoj.User.reopenClass
  current_user: ->
    request = ajax.request("/current_user/")

    request.then (user_data)->
      if user_data
        Theoj.User.create user_data
      else
        null

    request.catch (error)->
      null
