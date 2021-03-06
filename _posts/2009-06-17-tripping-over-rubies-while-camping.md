---
title:      Tripping over Rubies while Camping
created_at: 2009-06-17 12:00:00 +00:00
layout:     default
tags:       ruby
---

Today was another day like any other, but then I stopped and said hey "GO team!!". Okay not really, but it was a nice thought in retrospect. Anyway I gave birth to a little app called SvnMaster... the labour wasn't in the code, but rather debugging ActiveRecord 2.1.2 sqlite3 adapter and getting centos 5 up to speed. [Camping is a micro framework](http://redhanded.hobix.com/bits/campingAMicroframework.html) that was the perfect fit for the task. Maybe PHP was more appropriate for the problem domain. However, much like the previous sentence it wasn't how I wanted to express myself.
Working with Centos 5 and ruby feels like watching a cute fuzzy thing being hunted by predators. It's painful to watch, but given my current server environment it is a necessary evil. Understand I'm well familiar with the configure install shuffle (./configure && make && sudo make install), but it sure is a pain when it takes a couple of hours to get everything up to snuff.

The first thing I did was "gem update --system". Version 0.9.4, the default for Centos 5, sucks on small VPS's (mostly because it'll crash from resource constraints). I've been keeping up to date on Ruby so that's no worry, you may have to do the same.

So I can pull gems down to my hearts content, or can I? First up was RedCloth... long story short the gem uses Ragel and Centos 5 only provides version 5.x as an RPM. So a dependency hunting we will go. Building Ragel from source is pretty simple just follow the docs that are included. After Ragel was installed, RedCloth updated without any real complaints via gem install. Next was installing camping;

```ruby
gem install camping  # nuff said, installs 1.5 with ease
```

Once installed I started with some of the examples. I created the blog first just to wrap my head around the differences from Rails. Each class is a route... interesting. Anyway I started up the app (camping blog.rb) and all seemed fine... and then it hit I tried to login. Hmm curious the login doesn't work. I thought maybe there was a change with the way sessions worked so started reviewing the documentation on sessions. Everything seemed in order so what was happening, I wrote a boiled down session test and checked the logs and opened the DB... that's curious no entries or tables. So on with the search for my apps apparent lack of state.

### Active Campers lose weight when they've got state!

So ActiveRecord 2.1.0 doesn't play nicely with camping's session model out of the box. Found in a thread that you need to turn off partial updates;

```ruby
AppName::Models::Base.partial_updates = false
```


Booyah sessions work now! Well ActiveRecord in general does. After spending the better part of a rainy Saturday updating and debugging I finally had a working blog... on to my app! The app was really simple a form to provide the name of new repositories, an output listing of existing svn repositories, and some backend processing which created the repository from a template directory structure. The general idea was to provide an interface for the people I work with that would be quick, simple and consistent. All in all it came together rather quickly and I'm quite happy to have found a lovely new tool!
