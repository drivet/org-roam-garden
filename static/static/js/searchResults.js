(function (window, document) {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);

  function summarize(html) {
    const tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    const text = tmp.textContent || tmp.innerText || "";
    return text.length <= 200 ? text : text.slice(0, 200) + '[...]';
  }
  
  function search() {
    const field = urlParams.get('searchField');
    const results = window.lunrIndex.search(field);
    results.forEach(function(r) {
      r.doc = window.pagesIndex[r.ref];
    });
    const template =  document.getElementById(`searchResultsTemplate`).innerHTML;
    
    const compiledResult = Mustache.render(template, {
      field,
      hasResults: results.length > 0,
      results: results.map(r => ({
        uri: r.doc.uri,
        title: r.doc.title,
        truncated: summarize(r.doc.content)
      }))
    });
    
    const resEl = document.getElementById("searchResults");
    resEl.innerHTML = compiledResult;
  }
  
  fetch(`/index.json`).then((response) =>
    response.json().then((index) => {
      console.log(index);
      pagesIndex = index;
      lunrIndex = lunr(function() {
        this.field("title", { boost: 10 });
        this.field("tags", { boost: 5 });
        this.field("content");
        this.field("uri");
        this.ref("idx");
        pagesIndex.forEach(function (page, idx) {
          page.idx = idx;
          this.add(page);
        }, this);
      });
      
      search();
    })
  );
})(window, document);
