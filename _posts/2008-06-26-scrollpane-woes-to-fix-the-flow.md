---
title:      Scrollpane Woes to Fix the Flow
created_at: 2008-06-26 12:00:00 +00:00
layout:     default
tags: actionscript
---

Using the V2 ScrollPane component, externally loaded SWF’s may visually overflow outside of the defined ScrollPane area. Quite often the scrolling will still work, however the masking does not do its job as expected. In trying to solve the problem we have used everything from overloading the Loader class methods to simply calling invalidate briefly after the data loads.
h3. Coming to an understanding is part of the problem.

To fully understand the problem you need to go into the interaction between the Flash player, V2 components, and MovieClips. First off you will rarely, if ever, experience this problem in the Flash Developer environment. Why? The problem appears to be timing, and local files generally have no measurable load time relative to their web based counterparts. In your browser once the SWF has been cached the next refresh of the page generally works fine. Wipe your cache and watch the problem return.

### Where does the MovieClip class fit in?

MovieClip objects wipe their event handlers with a loadMovie, except the onClipEvent(), and variations of on(). For dynamically created clips it means you need to monitor the MovieClip outside of the MovieClip’s instance. On moderate to slow connections the ScrollPane seems to report a SWF file being loaded before it is actually complete, most likely because of the way it monitors the loading process.

### A Solution.

As mentioned previously we’ve tried a couple different methods to resolve this problem. While ours has its limitations it works where we need it to. The initial implementation was as follows:

    var check_loaded:Object = { _frequency: 500, 
      _intervalID: null,
      callback: null,
      pane: null,
    // start
      start: function() {
        this.stop( );// clear any running instances
        this._intervalID = setInterval( this, "checkPane", this._frequency );
        this.pane._visible = false;
      },  // ::start(...
    // stop
      stop: function() {
        if(this._intervalID !== null) {
          clearInterval(this._intervalID);
        }  // if(...
        this._intervalID = null;
      },  // ::stop(...
    // checkPane
      checkPane: function() { 
        var clip:MovieClip = this.pane.content;
        if( clip !== null ) {
          var total:Number = clip.getBytesTotal();
          var current:Number = clip.getBytesLoaded();
          // 36 is the size of a blank flash file
          if( current >= total && total >= 36 ) {
            this.stop( );
            this.pane.refreshPane( );
            this.pane._visible = true;
            if( this.callback !== null ) {
              this.callback( );
            }  // if(...
          }// if(...
          trace( current + " of " + total );
        }  // if(...
      }  // ::checkPane(...
    };

Enough already here’s how you use it with your ScrollPane.

    theScrollPane.contentPath = "CONTENT.swf";
    check_loaded.pane = theScrollPane;
    check_loaded.start( );

It works, but isn’t a clean OO implementation. A better approach is to reorganize the code into a separate ActionScript class. See [F3MaskPane](/images/F3MaskPane.as) for my implementation. With your new shiny class your code will look like below instead of the two blocks of code above.

    import F3MaskPane; 
    var check_loaded:F3MaskPane = new F3MaskPane( theScrollPane ); 
    theScrollPane.contentPath = "CONTENT.swf"; 
    check_loaded.start( );

### Notes and limitations on F3MaskPane.

If you depend/expect your border to be visible prior to loading content you’ll need to find another way.
The visibility of the ScrollPane is turned off to prevent the blink that occurs during the refreshPane call.
The F3MaskPane must not extend the Object class because of what appears to be a bug with calls to setInterval.
There is currently no upper limit on the number of iterations that checkPane will be called.
Audio maybe a problem because of the refreshPane.
That’s all for now.
