(function (window, document) {
    "use strict";
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
  
    const summarize = (html) => {
      const tmp = document.createElement("DIV");
      tmp.innerHTML = html;
      const text = tmp.textContent || tmp.innerText || "";
      return text.length <= 200 ? text : text.slice(0, 200) + '[...]';
    };
  
    const search = () => {
      const field = urlParams.get('searchField');
      const results = window.searchIndex.search(field);
      const template =  document.getElementById(`searchResultsTemplate`).innerHTML;
      const compiledResult = Mustache.render(template, {
        field,
        hasResults: results.length > 0,
        results: results.map(r => ({
          id: r.doc.id,
          title: r.doc.title,
          date: r.doc.date,
          truncated: summarize(r.doc.content)
        }))
      });
  
      const resEl = document.getElementById("searchResults");
      resEl.innerHTML = compiledResult;
    };
  
    fetch(`/lunridx.json`).then((response) =>
      response.json().then((rawIndex) => {
        window.searchIndex = elasticlunr.Index.load(rawIndex);
        search();
      })
    );
  })(window, document);
