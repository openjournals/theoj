# For more information see: http://emberjs.com/guides/routing/

Theoj.Router.map ()->
  @resource 'papers',{path: '/papers'}, ->
    @route 'assignment'
    @route 'review'
    @route 'submitted'

  @route 'about', path :'/about'
  @route 'people', path :'/people'
