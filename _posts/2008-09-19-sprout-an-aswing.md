---
title:      Sprout an AsWing
created_at: 2008-09-19 12:00:00 +00:00
layout:     default
tags:       actionscript
---

Looking to throw together a quick app in Flash to test Sprouts I decided on working with AsWing. Here's some of the process I followed to get the environment up and going.

Install the sprouts gem;

`# sudo gem install sprouts`

Download the latest aswing package;

[AsWing on Google Code](http://code.google.com/p/aswing/downloads/list)

Create a new project;

`# sprout -n as3 TickTock`

Copy AsWing.swc into TickTock/lib.

Modify the debug task in TickTock/rakefile.rb as illustrated:

    desc 'Compile and debug the application'
    debug :debug do |t|
      t.input = 'src/TickTock.as'
      t.library_path << "lib/AsWing.swc"
    end
