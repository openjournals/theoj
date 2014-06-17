# For more information see: http://emberjs.com/guides/routing/

Theoj.Router.map ()->


  @resource 'papers', ->
    @route 'submitted'
    @route 'in_review'
    @route 'accepted'
    @route 'waiting_assignment'
    @route 'reviewed'
    @route 'requires_review'
    @route 'waiting_on_author'

  @route    'submit_paper', {path:'/submit'}

  @resource 'paper', { path: '/paper/:id' }



  @resource 'index', {path: '/'} , ->
    @route 'about'
    @route 'how_to_submit'


  @route 'about', path :'/about'
  @route 'people', path :'/people'
