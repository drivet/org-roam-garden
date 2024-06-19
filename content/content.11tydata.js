const {titleCase} = require("title-case");

const sql = "select distinct l.source from nodes n, links l where n.file = 'filename' and n.id = l.dest";

function caselessCompare(a, b) {
    return a.normalize().toLowerCase() === b.normalize().toLowerCase();
}

module.exports = {
    layout: "note.html",
    type: "note",
    eleventyComputed: {
        title: data => {
            return titleCase(data.title || data.page.fileSlug);
        },
        permalink: (data) => `${data.page.filePathStem.replace('/content/', '')}.html`,
        backlinks: (data) => {
            const notes = data.collections.notes;
            const currentFileSlug = data.page.filePathStem.replace('/notes/', '');
            let backlinks = [];
            return backlinks;
        }
    }
}
