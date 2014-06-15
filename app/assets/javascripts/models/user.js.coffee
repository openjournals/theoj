Theoj.User = Ember.Object.extend()

Theoj.User.reopenClass

  current_user: ->
    return @current_user if @current_user
    $.getJSON "/current_user/", (user_data)->
      if user_data
        Theoj.User.create user_data
      else
        null
