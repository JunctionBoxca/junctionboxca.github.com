---
title:      Subversive Lyrics with Subversion
created_at: 2008-06-26 12:00:00 +00:00
layout:     default
tags: svn
---

The plan for today is to build an automated test environment (static websites only) that updates with each commit. Now I should forewarn you if you play this article backwards the devil will steal your dog, and wife, and leave you with nothing more than a crappy country song. Should that or anything else bad happen be an adult and take responsibility for your own actions, aka I'm not liable. Also if you don't know what subversion is this article is not a good place to start.
h3. Ingredients

-   Wildcard DNS
-   Apache 2.2
-   Subversion 1.4.x (SVN)
-   Your favourite scripting language
-   Back-ups, back-ups, back-ups!!!!!
-   Couple of hours

Okay so how is all of this going to look? Well lets say you have a client named Example and their website is located at example.com. The goal is to achieve a test site located at http://example.com.projects.myhost.ca/, it's a doozy to type, but it'll create consistency. Besides the amount of time spent typing will be more than offset by the time it saves you once configured properly.

### Initial Imports Insulate Against Insolence

Okay so lets say you've used svnadmin and created a webdav accessible repository at http://myhost.ca/svn/example.com/, how should the initial import look?

-   branches
-   tags
-   trunk
    -   site
    -   src

As you'll note it's a pretty vanilla setup for subversion. So moving forward we'll assume that trunk/site contains the latest and greatest of your clients website and trunk src is a dumping ground for your Illustrator, Photoshop, Actionscript and FLA's, etc.

### We Hosts Da Vhosts

So what's next? Lets get ready to rumble cuz we're going to create our vhost configuration. Pick your poison, but you can either append the following setup to your httpd.conf or add a new file named vhosts.conf in your conf.d folder.

    LogFormat "%V %h %l %u %t \"%r\" %s %b" vcommon

    <Directory /var/www/vhosts/project>
    # adjust override as you see fit
    AllowOverride All
    </Directory>

    <virtualhost *:80>
    ServerName *.projects.myhost.ca

    VirtualDocumentRoot /var/www/vhosts/projects/%-4+

    ErrorLog logs/projects.myhost.ca-error_log
    CustomLog logs/projects.myhost.ca-access_log vcommon
    </virtualhost>

### Sweet Script O'Mine

Where do we go now... GNR flashback... I think not! So we've got a repository and vhost now what? You've got 2 options here;
write a script that updates an existing checkout.
write a script that creates a checkout if it does not exist or updates if it does.
Option 1 is what I've gone with as I've placed the checkout in a script for the creation of my repository. The benefit to Option 2 is that it ensures you're checkout environment will have the right permissions for svn updates.

My script looks a little like the following;

    #!/usr/bin/ruby -w
    #
    # update.rb: Takes a repository URI as a single argument and uses the 
    #    last directory in the URI as part of the update path.
    #

    if ARGV.length != 1
     puts "You must specify a repository!"
    end

    # this folder must be owned by your webservers uid if you go with option 2
    PROJECTS_PATH='/var/www/vhosts/projects/'

    begin
     site_name = ARGV[0].split( /\// );
     site_name = site_name[site_name.length - 1]

     `svn update #{PROJECTS_PATH + site_name}`
    rescue
     # pick a error notification method log it, email it wuteva you want
    end

Now add this to the end of your post-commit hook as follows;

`/somepath/update.rb "$REPOS"`

Everytime you commit, it will automatically update a test copy of the site located at;

`http://example.com.projects.myhost.ca/`

### Conclusion

This is a simple way to give the whole family access to test websites without the clutter and extra time of using FTP.
