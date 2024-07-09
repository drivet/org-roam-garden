---
title: "All Notes"
author: ["Desmond Rivet"]
draft: false
layout: note.html
permalink: "{{ page.filePathStem }}.html"
---

Here is a full list ({{collections.notes | size}}) of every note in my garden.

{% for note in collections.notes %}
* <a href="{{note.url}}">{{note.data.title}}</a>
{%- endfor -%}
