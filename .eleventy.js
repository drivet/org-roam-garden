const elasticlunr = require("elasticlunr");
const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
const timezone = require('dayjs/plugin/timezone');
dayjs.extend(utc);
dayjs.extend(timezone);

function dateFormat(date, format) {
    return dayjs(date).tz('America/Montreal').format(format);
}
  
function searchNotesInit() {
    const index = elasticlunr();
    index.addField("title");
    index.addField("date");
    index.addField("tags");
    index.addField("content");
    index.setRef("id");
    return index;
}

function searchNotesIdx(post, index) {
    index.addDoc({
      id: post.url,
      title: post.data.title,
      date: dateFormat(post.date, 'MMM D, YYYY, h:mm A Z'),
      tags: post.data.tags,
      content: post.templateContent
    });
}

function idxJson(index) {
    return index.toJSON();
}
  
module.exports = function(eleventyConfig) {
    eleventyConfig.setBrowserSyncConfig(
        require('./configs/browsersync.config')('_site')
    );
    const markdownIt = require('markdown-it');
    const markdownItOptions = {
        html: true,
        linkify: true
    };
    
    const md = markdownIt(markdownItOptions)
        .use(require('markdown-it-footnote'))
        .use(require('markdown-it-attrs'))
    
    eleventyConfig.addFilter("markdownify", str => md.render(str))
    eleventyConfig.addFilter("searchNotesInit", searchNotesInit);
    eleventyConfig.addFilter("searchNotesIdx", searchNotesIdx);
    eleventyConfig.addFilter("idxJson", idxJson);
    eleventyConfig.addFilter("dump", obj => JSON.stringify(obj));

    eleventyConfig.setLibrary('md', md);
    
    eleventyConfig.addCollection("notes", function (collection) {
        return collection.getFilteredByGlob(["content/**/*.md"]);
    });
    
    eleventyConfig.addPassthroughCopy('assets');
    
    eleventyConfig.setUseGitIgnore(false);
   

    return {
        dir: {
            input: "./",
            output: "_site",
            layouts: "layouts",
            includes: "includes",
            data: "_data"
        },
        passthroughFileCopy: true
    }
}
