---
title:      Simplified TDD with Sinatra autotest
created_at: 2010-04-17 12:00:00 +00:00
layout:     default
tags:       ruby testing
---

General overview of what we're building;

-   Simple autotest compatible directory structure.
-   Sinatra application.
-   Sinatra unit test.

File setup:


    export project=MyApp
    mkdir -p $project/{lib,test}
    cd $project
    cat <<EOT > test/test_app.rb
    $:.unshift File.join(File.dirname(__FILE__),'..','lib')

    require 'app'
    require 'test/unit'

    class AppTest < Test::Unit::TestCase
      def test_fail
        flunk 'Write your App tests!'
      end
    end
    EOT

    autotest

This should output something akin to the following, if you don't get that then somethings amiss that you'll need to investigate further.

    /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `gem_original_require': no such file to load -- app (LoadError)
      from /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `require'
      from ./test/test_app.rb:4
      from /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `gem_original_require'
      from /Library/Ruby/Site/1.8/rubygems/custom_require.rb:31:in `require'
      from -e:2
      from -e:2:in `each'
      from -e:2

Next create a new file named 'lib/app.rb'.

`touch lib/app.rb`

Once saved your test should kick to life with one failure:


    1) Failure:
    test_fail(AppTest) [./test/test_app.rb:8]:
    Write your App tests!.

Hugely simplified test suite, but it gets you going and doesn't contain reams of mystical cruft to debug.

Next up is introducing rack's test suite, modify your test\_app.rb to look like the following;


    $:.unshift File.join(File.dirname(__FILE__),'..','lib')

    require 'app'
    require 'test/unit'
    require 'rack/test'

    set :environment, :test

    class AppTest < Test::Unit::TestCase
      include Rack::Test::Methods

      def app
        App
      end

      def test_fail
        flunk 'Write your App tests!'
      end
    end

Back to a test that doesn't run? Good!

Let's get it back to a running test with the following change to 'lib/app.rb':

    %w{rubygems sinatra}.each {|l| require l }

Now you should have a failing test. Lets start on something meaningful remove the test\_fail method and add the following:


    def test_root_is_accessible
      get '/'
      assert last_response.ok?
    end

Your autotest should switch to the error output below:


    1) Error:
    test_root_is_accessible(AppTest):
    NameError: uninitialized constant AppTest::App
    ./test/test_app.rb:13:in `app'

That's an indicator we're missing our application class. Dealing with one problem at a time lets implement the skeleton class in 'lib/app.rb' as outlined below.

    class App < Sinatra::Base
    end

You should get a failing test case with the output below, which indicates the route is not found.

    1) Failure:
    test_root_is_accessible(AppTest) [./test/test_app.rb:18]:
    <false> is not true.

Next up lets add the route in 'lib/app.rb'.


    get '/' do
    end

And there we go our first of hopefully many tests is now passing, congratulations!

For the source see;

<git://github.com/nfisher/Sinatra-Skeleton.git>
