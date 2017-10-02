---
title:      Fresh Book It
created_at: 2010-02-23 12:00:00 +00:00
layout:     default
---

A few years ago I signed up for a [Freshbooks](http://www.freshbooks.com/) account while I was running my own business. A year and a half later I was employed at a small start-up that had about 12 people. I was involved in much of the software selection and design of some of our core infrastructure. We needed a time tracking system. My suggestion was Freshbooks as there was the potential to integrate it with some of our other systems.

We're now close to 100 people, and over 200 projects. Freshbooks project selection just isn't cutting it anymore, but I was sure there was a solution, namely a project selector with type ahead search.

One late night at work, waiting for a **large** db dump to load, I decided to do a little hacking. I cracked open the page source to see what JS framework was used. JQuery was available and I was elated! Firebug was up next. I was pretty certain I could pull the data I wanted from the Project selection box. I got the id from the inspector, fired up the console and started poking around.

I came up with some code that worked in the console and turned it into a one-liner for a bookmarklet... and presto...fizzo. No dice, no workie... just rendered \[Object object\].

Hmmm so I did a little research and found that var assignments act like a return which explains the \[Object object\]. A little googling and I found what I hoped to be the solution;

`(function(){})()`
Okay that dealt with the \[Object object\] problem, but sadly not the solution I was looking for. The javascript errors were coming on fast and furious because of variable scope.

Now I know when you look at the code you'll scream "GLOBALS ARE BAD", but its a bookmarklet and I was just having fun with javascript.

Turns out my solution was to wrap the variable initialization in void().

`void(project_list = null)`

Hold the applause, but here's the final code (for now :).

    javascript:
    void(project_list = null);
    void(project_select = null);

    function init( ) {
            project_list = $('#projectid option');
            project_select = $('#projectid');
            search_box = '<input type="text" onkeyup="projectSearch(this);" style="width:200px" id="search_entry"/><div id="search_results" style="position:absolute;width:22em;overflow:auto;max-height:12em;"></div>';
            project_select.css('visibility','hidden');
            project_select.after(search_box);
    }

    function projectSearch($target) {
            var re = new RegExp('.*' + $target.value + '.*$','i');
            var search_results = $('#search_results');
            var links = '';
            search_results.empty();
            project_list.each( function($index, $element) {
                if( $element.text.match(re) && parseInt($element.value) > 0 ) {links += projectLink( $element.value, $element.text );}
              });
            search_results.prepend(links);
    }

    function updateSelection( $id, $label ) {
            project_select.val($id);
            project_select.change();
            $('#search_entry').val($label);
            $('#search_results').empty();
    }

    function projectLink( $id, $label ) {
            return '<a href="#" style="display:block;clear:both;background-color:#ccc;border-bottom:1px solid #999;padding:4px 2px;" onclick="updateSelection(\''+ $id + '\',\'' + $label +'\');return false;">' + $label + '</a>';
    }

    init();
