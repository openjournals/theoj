Theoj.UserLookupComponent = Ember.Component.extend
  userList: []
  currentSelected: null
  currentGuess: ""

  actions:
    selectUser: (username)->
      @sendAction('action', username)
      @reset()

  reset:->
    @set "userList", []
    @set "currentGuess", ""

  currentGuessChanged:(->
    if @currentGuess.length > 0
      ajax.request("/user/name_lookup?guess=#{@currentGuess}").then (names) =>
        console.log @userList
        @set 'userList', Em.A(names)
        window.ULC = @
    else
      @set "userList", []

  ).observes('currentGuess')
