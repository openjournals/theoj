Theoj.FullPaperViewerComponent = Ember.Component.extend
  page          : 0
  scale         : 1
  pages         : []
  totalPages    : null
  pdf_url       : null
  selection     : null

  #FIXME need to use the proper lifetime hook for component rendering on page rather
  #than stupid time out

  didInsertElement:->
    PDFJS.workerSrc = '/pdf.worker.js';

    promise  = PDFJS.getDocument(@pdf_url)
    window.pdfjspromise = promise
    request = promise.then (pdfDoc)=>
      @set 'pdfDoc', pdfDoc
      @set 'pages', [1..pdfDoc.numPages]
      @set 'totalPages' , @pdfDoc.numPages

      setTimeout =>
        @renderPages()
      , 200

    window.pdfRequst = request

  pageObserver:->
    @renderPage()

  renderPages:->
    for page in @pages
      @renderPage page , "#paper-page-#{page}"

  scaleObserver:->
    @renderPage()

  renderPage:(pageNo, target)->
    #Using promise to fetch the page

    console.log "width, "+$(target)[0].width + ' height ' + $(target)[0].height
    @pdfDoc.getPage(pageNo).then (page)=>
      canvas = $(target)[0]
      ctx = canvas.getContext('2d')
      viewport = page.getViewport(2);
      canvas.height = viewport.height;
      canvas.width = viewport.width;

      console.log $("#paper-text-layer-page-#{pageNo}")[0], $(target)[0], pageNo

      page.getTextContent().then  (textContent)->
        textLayer = new TextLayerBuilder
          textLayerDiv: $("#paper-text-layer-page-#{pageNo}")[0]
          viewport: viewport
          pageIndex: pageNo


        window.textLayer = textLayer
        textLayer.setTextContent(textContent)
        textLayer.render()

      page.render
        canvasContext: ctx
        viewport: viewport

  actions:

    nextPage: ->
      @page+=1
      @page = Math.max(1,@page)

    prevPage:->
      @page-=1
      @page = Math.max(@totalPages,@page)

    home:->
      @page = 1

    search:->
      alert("searching")
