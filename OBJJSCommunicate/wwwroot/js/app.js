'use strict';

angular.module('iqos', [
  'ui.router'
]).

config([
  '$stateProvider', '$urlRouterProvider',
function(
  $stateProvider, $urlRouterProvider
) {

  console.log('Configuring...');

  // For any unmatched url, redirect to /
  $urlRouterProvider.otherwise('/');

  // Now set up the states
  $stateProvider.
    // Home screen for the app
    state('application', {
      abstract: true,
      controller: 'AppCtrl',
      templateUrl: 'templates/application.html',
      url: ''
    }).
    state('application.main', {
      controller: 'MainCtrl',
      templateUrl: 'templates/main.html',
      url: '/'
    }).
    state('application.search', {
      controller: 'SearchCtrl',
      templateUrl: 'templates/search.html',
      url: '/search'
    })
  ;
}]).

controller('AppCtrl', [
  '$log', '$scope',
function (
  $log, $scope
) {

  $log.info('Loading AppCtrl...');

}]).

controller('MainCtrl', [
  '$log', '$scope',
function (
  $log, $scope
) {

  $log.info('Loading MainCtrl...');

}]).

controller('SearchCtrl', [
  '$log', '$scope',
function (
  $log, $scope
) {

  $log.info('Loading SearchCtrl...');

}])

;
