Theoj.Annotation = Ember.Object.extend
    id: null
    comments:[]
    text:""
    state:"pending"
    author: null

    resolve:->
      ajax.request
        url: "/annotations/#{@id}/resolve"
        type: "POST"
        data:
          user_name: username

    add_comment:(comment)->
      ajax.request
        url: "/annotations/#{@id}/comment"
        type: "POST"
        data:
          user_name: comment
