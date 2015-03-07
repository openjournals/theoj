(function() {

    function clean1(text, ignored_) { return (text || '')+' '};

    function HeadingRenderer(options) {
        this.options = options || {};
    }

    HeadingRenderer.prototype = new marked.Renderer();

    HeadingRenderer.prototype.heading    = clean1;
    HeadingRenderer.prototype.blockquote = clean1;
    HeadingRenderer.prototype.html       = clean1;
    HeadingRenderer.prototype.hr         = clean1;
    HeadingRenderer.prototype.list       = clean1;
    HeadingRenderer.prototype.listitem   = clean1;
    HeadingRenderer.prototype.paragraph  = clean1;
    HeadingRenderer.prototype.table      = clean1;
    HeadingRenderer.prototype.tablerow   = clean1;
    HeadingRenderer.prototype.tablecell  = clean1;

    HeadingRenderer.prototype.code = function(code, lang, escaped) {
        return '<code>' + escaped ? code : escape(code, true) + '</code>';
    };


    // span level renderer
    // All inherited from default Renderer (strong, em, codespan, br, del)

    HeadingRenderer.prototype.link = function(href, title, text) { return text; };
    HeadingRenderer.prototype.image = function(href, title, text) { return text; }

    window.HeadingRenderer = HeadingRenderer;

    window.strip_markdown = function(markup) {
      if (!window.headingRenderer)
          window.headingRenderer = new HeadingRenderer();
      return marked.parse(markup, {renderer:window.headingRenderer} );
    };

}());
