(function() {

    function clean1(text, ignored_) { return (text || '')+' '};
    function clean2(text, ignored_) { return (text || '')};

    function StrippedMarkdownRenderer(options) {
        this.options = options || {};
    }

    StrippedMarkdownRenderer.prototype = new marked.Renderer();

    StrippedMarkdownRenderer.prototype.heading    = clean1;
    StrippedMarkdownRenderer.prototype.blockquote = clean1;
    StrippedMarkdownRenderer.prototype.html       = clean1;
    StrippedMarkdownRenderer.prototype.hr         = clean1;
    StrippedMarkdownRenderer.prototype.list       = clean1;
    StrippedMarkdownRenderer.prototype.listitem   = clean1;
    StrippedMarkdownRenderer.prototype.paragraph  = clean1;
    StrippedMarkdownRenderer.prototype.table      = clean1;
    StrippedMarkdownRenderer.prototype.tablerow   = clean1;
    StrippedMarkdownRenderer.prototype.tablecell  = clean1;

    StrippedMarkdownRenderer.prototype.code = function(code, lang, escaped) {
        return escaped ? code : escape(code, true);
    };

    // span level renderer
    // All inherited from default Renderer (strong, em, codespan, br, del)

    StrippedMarkdownRenderer.prototype.strong   = clean2;
    StrippedMarkdownRenderer.prototype.em       = clean2;
    StrippedMarkdownRenderer.prototype.codespan = clean2;
    StrippedMarkdownRenderer.prototype.text     = clean2;

    StrippedMarkdownRenderer.prototype.br    = function() { return "\n"; };
    StrippedMarkdownRenderer.prototype.link  = function(href, title, text) { return text || title; };
    StrippedMarkdownRenderer.prototype.image = function(href, title, text) { return text || title; };

    window.StrippedMarkdownRenderer = StrippedMarkdownRenderer;

    window.stripped_markdown = function(markup) {
      if (!window.strippedMarkdownRenderer)
          window.strippedMarkdownRenderer = new StrippedMarkdownRenderer();
      return marked.parse(markup || '', {renderer:window.strippedMarkdownRenderer} );
    };

}());
