const {titleCase} = require("title-case");
const sqlite = require('better-sqlite3');
const path = require('path');

function getBacklinks(filepath) {
  const absfile = path.resolve(`./org-roam/${filepath}.org`);
  const db = new sqlite('./org-roam/.org-roam.db');
  const rows = db.prepare(`SELECT file, title FROM nodes WHERE id IN (SELECT DISTINCT l.source AS source FROM nodes n, links l WHERE n.file = '"${absfile}"' AND n.id = l.dest)`).all();
  const absroot = path.resolve('.');
  const backlinks = rows.map(r => {
    // strip quotes I think
    const title = r.title.slice(1, -1);
    // strip quotes and .org
    const file = r.file.slice(1,-5).replace(`${absroot}/org-roam/`, '');
    return { url: file, title: title };
  });
  db.close();
  return backlinks || [];
}

module.exports = {
  layout: "default.html",
  type: "note",
  eleventyComputed: {
    title: data => titleCase(data.title || data.page.fileSlug),
    permalink: (data) => `${data.page.filePathStem.replace('/content/', '')}.html`,
    backlinks: (data) => {
      const currentFileSlug = data.page.filePathStem.replace('/content/', '');
      const backlinks = getBacklinks(currentFileSlug);
      return backlinks;
    }
  }
}
