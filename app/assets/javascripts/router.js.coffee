# For more information see: http://emberjs.com/guides/routing/

Theoj.Router.map ()->
  
  @route    'papers'      , {path:'/papers/:type'}
  @route    'submit_paper', {path:'/submit'}
  @resource 'paper'       , {path:'/paper/:id'}

  @resource 'index', {path: '/'} , ->
    @route 'about'
    @route 'how_to_submit'


  @route 'about', path :'/about'
  @route 'people', path :'/people'
  @resource('papers')
  @route 'about', path: '/about'
