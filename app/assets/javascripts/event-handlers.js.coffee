HTMLImports.whenReady ->

  # Hide Drawer Toggle When in narrow mode
  $('#toolbar .drawer-toggle').toggle( Oj.app().narrow );

  # Toggle Drawer from Toolbar
  $('#toolbar .drawer-toggle').on 'click', (event) ->
    Oj.app().toggleDrawer();

  # Handle Enter key in search field
  $('#search').on 'keyup', (event) ->
      if event.keyCode == 13
        event.preventDefault();
        value = $('#search').val();
        value = value && $.trim(value);
        if value
          Oj.app().fire('go', '/search?q=' + encodeURIComponent(value));
