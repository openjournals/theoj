Ember.Handlebars.helper 'simple_pdf_view', (url, options)->
  if url
    new Ember.Handlebars.SafeString  "<iframe src='#{url}&embedded=true' width='600' height='780' style='border: none;'></iframe>"
  else
    new Ember.Handlebars.SafeString "Enter Url to preview"
