---
title:      Kick dependence, here's an injection
created_at: 2009-11-03 12:00:00 +00:00
layout:     default
tags:       php
---

Recently I have been mulling the benefits of Dependency Injection in relationship to PHP. I still question it's need, but I felt like an experiment for the fun of it.

First I laid out the general interface I wanted to work with. You may recognize it as being very similar to [this](http://onestepback.org/index.cgi/Tech/Ruby/DependencyInjectionInRuby.rdoc) shamelessly "php'ized" ruby code.

    function create_app() {
     $container = new DI_Container( );
     $container->register( 'logfilename', 'logfile.log' );
     $container->register( 'db_user', 'nfisher' );
     $container->register( 'db_pass', 'secret' );
     $container->register( 'dbi_string', 'db:host:and:stuff' );

     $container->register( 'authenticator', function($c) {
      return new Authenticator( $c->database, $c->logger, $c->error_handler );
    } );

     $container->register('error_handler', function($c) {
      $errh = new ErrorHandler( );
      $errh->logger = $c->logger;
      return $errh;
    } );

     $container->register('logger', function($c) {
      return new Logger( $c->logfilename );
    } );

     $container->register('database', function($c) {
      return new DB( $c->dbi_string, $c->db_user, $c->db_pass );
    } );

     $container->register('quotes', function($c) {
      return new StockQuotes( $c->error_handler, $c->logger );
    } );

     $container->register('webapp', function($c) { 
      $app = new WebApp( $c->quotes, $c->authenticator, $c->database );
      $app->logger = $c->logger;
      $app->set_error_handler( $c->error_handler );
      return $app;
    } );
    }

Now I had a couple issues with the above implementation; string constants, and anonymous functions.

### String Constants Aren't Unknown Objects

The DB/logfile config are not really dependencies. It seems better to decouple them into a configuration class that can be initialized based on environment (ie/ dev, test, prod).

### Absence of Anonymous Functions

Unfortunately my production environment is php 5.2, anonymous functions...5.3 so its a simple problem of what's more important... existing well tested env won out on that one.

So I created a simple function binder with the following interface;

    interface Applyable {
     public function each( $o );
    }

    class FunctionBinder implements Applyable {
      private $_f_name;

      public function __construct( $f_name ) {
        $this->_f_name;
      }

      /** each: Calls the stored function by name and passes the DI container as a reference. 
       */
      public function each( $c ) {
        return call_user_func( $this->_f_name, $c );
      }
    }

The anonymous function became named;

    function create_logger( $c ) {
      return new Logger( $c->logfilename );
    }

And the register became;

```
$container->register('logger', new FunctionBinder('create_logger') );
```

### Code check in aisle 3... code check

Trying to be a good little coder I built my tests first for the container. I decided I would use the \_*get method to build the graphs the question was how! My first naive approach was to throw exceptions from the*\_get method for currently incomplete objects. As exceptions were thrown an immediate depth of dependencies would be identified through the exception handler...okay it'll work, but it ain't gonna be pretty. If your dependencies are spectacularly out of order it seems like an excessive unwinding of the call stack will occur just to keep the code down.

### Testing 1.. 2

The next thought that occurred to me was why not include the dependencies with the registration process?

`$container->register( 'logger', new FunctionBinder('create_logger'), 'logfilename' );`

It seemed simple, but I didn't like it. My dependencies were clearly defined inside of the create\_logger function. Why duplicate effort, especially when it could potentially lead to an error.

### Put on trial and Execute

While cooking dinner it dawned on me, why should the objects be instantiated directly? After all the goal is to minimize the usage of the new operator? Factories to the rescue!

    function create_logger( $c ) {
     return $c->build( Logger, $c->logfilename );
    }

How does that change things? Well it allows for a 2 phase process;

Phase 1: Evaluate dependencies.
Phase 2: Instantiate objects.

During Phase 1 no objects are actually built. Instead evaluate the object requests and associate their dependencies.
Phase 2 is executed as soon as each objects dependencies are fulfilled. If an object has all of its dependencies fulfilled immediately then it is instantiated, otherwise it sits on the back burner waiting for it's time.

I have a direction, stay tuned for the final product!
