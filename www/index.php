<?php
session_start();
$_SESSION["isLog"]=false;
/**
 * Step 1: Require the Slim Framework
 *
 * If you are not using Composer, you need to require the
 * Slim Framework and register its PSR-0 autoloader.
 *
 * If you are using Composer, you can skip this step.
 */
require 'Slim/Slim.php';

\Slim\Slim::registerAutoloader();

/**
 * Step 2: Instantiate a Slim application
 *
 * This example instantiates a Slim application using
 * its default settings. However, you will usually configure
 * your Slim application now by passing an associative array
 * of setting names and values into the application constructor.
 */
$app = new \Slim\Slim();

/**
 * Step 3: Define the Slim application routes
 *
 * Here we define several Slim application routes that respond
 * to appropriate HTTP request methods. In this example, the second
 * argument for `Slim::get`, `Slim::post`, `Slim::put`, and `Slim::delete`
 * is an anonymous function.
 */

// GET route
$app->get('/', function () {
   include 'report/greport.php';

});


//Routes for reports
$app->get('/report/global/', function () {
  include 'report/greport.php';
});

$app->get('/report/hosts/', function () {
  include 'report/hreport.php';
});

$app->get('/report/groups/', function () {
  include 'report/gpreport.php';
});

$app->get('/report/types/', function () {
  include 'report/treport.php';
});

//Route for host
$app->get('/host/show/:id/', function ($id) {
  include 'host/view.php';
  hostView($id);
});

$app->get('/host/add/', function () {
  include 'report/treport.php';
});

$app->get('/host/rem/', function () {
  include 'report/treport.php';
});

$app->get('/host/rem/:id/', function ($id) {
  include 'report/treport.php';
});

$app->get('/host/edit/', function () {
  include 'report/treport.php';
});

$app->get('/host/edit/:id/', function ($id) {
  include 'report/treport.php';
});

//Route for Group
$app->get('/group/show/:id/', function ($id) {
  include 'group/view.php';
  groupView($id);
});

$app->get('/group/add/', function () {
  include 'report/treport.php';
});

$app->get('/group/rem/', function () {
  include 'report/treport.php';
});

$app->get('/group/rem/:id/', function ($id) {
  include 'report/treport.php';
});

$app->get('/group/edit/', function () {
  include 'report/treport.php';
});

$app->get('/group/edit/:id/', function ($id) {
  include 'report/treport.php';
});

//Route for Types
$app->get('/type/show/:id/', function ($id) {
  include 'type/view.php';
  typeView($id);
});

$app->get('/type/add/', function () {
  include 'report/treport.php';
});

$app->get('/type/rem/', function () {
  include 'report/treport.php';
});

$app->get('/type/rem/:id/', function ($id) {
  include 'report/treport.php';
});

$app->get('/type/edit/', function () {
  include 'report/treport.php';
});

$app->get('/type/edit/:id/', function ($id) {
  include 'report/treport.php';
});

//Route for search
$app->get('/search/', function () {
  include 'search/search.php';
});

// POST route
$app->post('/post', function () {
    echo 'This is a POST route';
});

// PUT route
$app->put('/put', function () {
    echo 'This is a PUT route';
});

// DELETE route
$app->delete('/delete', function () {
    echo 'This is a DELETE route';
});

/**
 * Step 4: Run the Slim application
 *
 * This method should be called last. This executes the Slim application
 * and returns the HTTP response to the HTTP client.
 */
$app->run();
