(function() {

    function clean1(text, ignored_) { return (text || '')+' '};

    function SimplifiedMarkdownRenderer(options) {
        this.options = options || {};
    }

    SimplifiedMarkdownRenderer.prototype = new marked.Renderer();

    SimplifiedMarkdownRenderer.prototype.heading    = clean1;
    SimplifiedMarkdownRenderer.prototype.blockquote = clean1;
    SimplifiedMarkdownRenderer.prototype.html       = clean1;
    SimplifiedMarkdownRenderer.prototype.hr         = clean1;
    SimplifiedMarkdownRenderer.prototype.list       = clean1;
    SimplifiedMarkdownRenderer.prototype.listitem   = clean1;
    SimplifiedMarkdownRenderer.prototype.paragraph  = clean1;
    SimplifiedMarkdownRenderer.prototype.table      = clean1;
    SimplifiedMarkdownRenderer.prototype.tablerow   = clean1;
    SimplifiedMarkdownRenderer.prototype.tablecell  = clean1;

    SimplifiedMarkdownRenderer.prototype.code = function(code, lang, escaped) {
        return '<code>' + escaped ? code : escape(code, true) + '</code>';
    };


    // span level renderer
    // All inherited from default Renderer (strong, em, codespan, br, del)

    // SimplifiedMarkdownRenderer.prototype.link = function(href, title, text) { return text; };
    SimplifiedMarkdownRenderer.prototype.image = function(href, title, text) { return text || title; }

    window.SimplifiedMarkdownRenderer = SimplifiedMarkdownRenderer;

    window.simplified_markdown = function(markup) {
      if (!window.simplifiedMarkdownRenderer)
          window.simplifiedMarkdownRenderer = new SimplifiedMarkdownRenderer();
      return marked.parse(markup, {renderer:window.simplifiedMarkdownRenderer} );
    };

}());
