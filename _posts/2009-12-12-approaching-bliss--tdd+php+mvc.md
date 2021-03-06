---
title:      Approaching bliss; TDD+PHP+MVC
created_at: 2009-12-12 12:00:00 +00:00
layout:     default
tags:       php testing
---

Started getting back into CodeIgnitor, but the one thing I was really missing from Rails is a test framework. As much as it doesn't seem to have the same ongoing support and uptake as PHPUnit, I have a certain affinity to the SimpleTest framework. I decided to see what ramblings there were regarding TDD and CodeIgnitor on the interweb. In my search I ran across the article [Setting up the perfect CodeIgniter & TDD Environment](http://jamierumbelow.net/2009/08/11/setting-up-the-perfect-codeigniter-tdd-environment/). I downloaded the code and massaged it a little to suit my needs. I'm not fully content with the implementation of BaseTestPath, but I'm sure a round of TDD (which I should've started with) will probably iron it out. Kudos to Jamie for doing the heavy lifting!
It hasn't been thoroughly tested, so use at your own peril. Specifically I haven't verified the views section, but upon initial inspection unit tests work. I'm thinking generate and destroy functions that build out the skelton for models, controllers, views might be my next step.

    <?php
    /*
    SimpleTest + CodeIgniter

    test.php

    the test runner - loads all needed files, integrates with CodeIgniter and runs the tests 

    Written by Jamie Rumbelow
    http://jamierumbelow.net/

    Modifications by Nathan Fisher
    http://junctionbox.ca/

    Notes on Directory structure; where ./ is the root of a fresh CI project.

    ./test.php
    ./system/test # symlink or similar to root of SimpleTest folder
    ./system/application/tests
    ./system/application/tests/models
    ./system/application/tests/views
    ./system/application/tests/controllers

    Changes:

      * Added console writer for test suite.
      * Moved all of the file scanning into classes.
      * Fixed a bug where vim swp files are treated as test classes.
      * Fixed a bug where view files can never exclusively be processed.

    Todo:

      * Unit Tests - how ironic :(
      * Fix potential problem if test folders do not exist.

    License:

    Free to use however you please... if it causes harm in anyway the authors are not liable.


    */

    //Configure and load files
    define('ROOT', dirname(__FILE__) . '/');
    define('APP_ROOT', ROOT . 'system/application/');

    require_once ROOT . 'system/test/unit_tester.php';
    require_once ROOT . 'system/test/web_tester.php';
    require_once ROOT . 'system/test/reporter.php';

    class CodeIgniterUnitTestCase extends UnitTestCase {
      protected $ci;

      public function __construct() {
        parent::UnitTestCase();
        $this->ci =& get_instance();
      }
    }

    class CodeIgniterWebTestCase extends WebTestCase {
      protected $ci;

      public function __construct() {
        parent::WebTestCase();
        $this->ci =& get_instance();
      }
    }

    function add_full_path( &$v, $k, $o ) {
      $o->addImplementationPath($o->getImplementationPath($v));
      $v = $o->getTestPath() . '/' . $v;
    }

    function filter_hidden( $v ) {
      if( preg_match('/^\./', $v) ) {
        return FALSE;
      }

      return TRUE;
    }


    /**
     * BaseTestPath:
     *
     */
    abstract class BaseTestPath {
      abstract function getTestPath();
      abstract function getImplementationPath($test);

      var $is_fullpath = FALSE;
      var $filenames = null;
      var $impl_filenames = array();

      function getFilenames() {
        if( $this->filenames === null ) {
          $this->filenames = @scandir($this->getTestPath());
          $this->filenames = array_filter( $this->filenames, 'filter_hidden' );
        }
        return $this->filenames;
      }

      function addToTestSuite( &$test ) {
        $this->loadImplementations();
        foreach( $this->getFilenamesWithFullPath() as $test_file ) {
          $test->addFile( $test_file );
        }
      }

      function loadImplementations() {
        $this->getFilenamesWithFullPath();
        foreach( $this->impl_filenames as $impl ) {
          if( file_exists($impl) ) {
            require_once($impl);
          }
        }
      }

      function getFilenamesWithFullPath() {
        if( $this->is_fullpath == FALSE ) {
          $this->getFilenames();
          array_walk( $this->filenames, 'add_full_path', $this );
          $this->is_fullpath = TRUE;
        }

        return $this->filenames;
      }

      function addImplementationPath( $impl_path ) {
        array_push($this->impl_filenames, $impl_path);
      }
    }


    /**
     * ControllerTestPath:
     *
     */
    class ControllerTestPath extends BaseTestPath {
      function getTestPath() {
        return APP_ROOT . 'tests/controllers';
      }

      function getImplementationPath( $test_filename ) {
        $controller = preg_replace( '#.*?([a-zA-Z0-9_\-]+)_controller_test.php$#', '$1.php', $test_filename );
        return APP_ROOT . 'controller/' . $controller;
      }
    }


    /**
     * ModelTestPath:
     *
     */
    class ModelTestPath extends BaseTestPath {
      function getTestPath() {
        return APP_ROOT . 'tests/models';
      }

      function getImplementationPath($test_filename) {
        $model = preg_replace('#.*?([a-zA-Z0-9_\-]+_model)_test.php$#', '$1.php', $test_filename);
        return APP_ROOT . 'models/' . $model;
      }
    }


    /**
     * ViewTestPath:
     *
     */
    class ViewTestPath extends BaseTestPath {
      function getTestPath() {
        return APP_ROOT . 'tests/views';
      }

      function getImplementationPath( $test_filename ) {
        $view = preg_replace('#.*?([a-zA-Z0-9_\-]+)_view_test.php$#', '$1.php', $test_filename);
        $view = implode( '/', explode('_',$view) );
        return APP_ROOT . 'views/' . $view;
      }
    }


    //Capture CodeIgniter output, discard and load system into $CI variable
    ob_start();
    include(ROOT . 'index.php');
    $CI =& get_instance();
    ob_end_clean();

    //Setup the test suite
    $test_suite =& new TestSuite();
    $test_suite->_label = 'CodeIgniter Application Test Suite';

    $controller_tests = new ControllerTestPath();
    $model_tests = new ModelTestPath();
    $view_tests = new ViewTestPath();
    $tests = array();

    if( isset($_GET['controllers']) ) {
      array_push( $tests, $controller_tests );
    }

    if( isset($_GET['models']) ) {
      array_push( $tests, $model_tests );
    }

    if( isset($_GET['views']) ) {
      array_push( $tests, $view_tests );
    }

    if( sizeof($tests) == 0 ) {
      $tests = array( $model_tests, $view_tests, $controller_tests );
    }

    foreach( $tests as $test ) {
      $test->addToTestSuite( &$test_suite );
    }

    //Run tests!
    if (TextReporter::inCli()) {
      exit ($test_suite->run(new TextReporter()) ? 0 : 1);
    }
    $test_suite->run(new HtmlReporter());

    /* End of file test.php */
    /* Location: ./test.php */
