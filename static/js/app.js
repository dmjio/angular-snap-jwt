var app = angular.module("app", ['ngRoute']);

app.controller("homeController", function($scope, $location, $window) {
    $scope.message = "hi main";
    $scope.logout = function() {
        if (!$window.sessionStorage.token) {
            console.log('token doesnt exist');
            $location.url('/login');
        } else {
            console.log('token exists');
            delete $window.sessionStorage.token;
            $location.url('/');
        }
    };
});

app.controller("loginController", function($scope, $http, $location, $window) {
    $scope.message = "hi login";
    $scope.user = {};
    $scope.login = function() {
        var req = { 
            method : 'POST', 
            url : '/api/login', 
            data : { 
                username : $scope.user.username,
                password : $scope.user.password
            }
        };
        $http(req).success(function(token, headers, config) {
            $window.sessionStorage.token = token;
            $location.url('/data');
        }).error(function(status, headers, config) {
            console.log('error', status, headers, config);
        });
    };
});

app.controller("registerController", function($scope, $http, $location, $window) {
    $scope.user = {};
    $scope.register = function() {
        var req = { 
            method : 'POST', 
            url : '/api/register', 
            data : { 
                username : $scope.user.username,
                password : $scope.user.password
            }
        };
        $http(req).success(function(token, headers, config) {
            console.log('success', token, headers, config);
            console.log(token, 'got it!');
            $window.sessionStorage.token = token;
            $location.url('/');
        }).error(function(status, headers, config) {
            console.log('error', status, headers, config);
        });
    };
});

app.controller("contactController", function($scope) {
    $scope.message = "hi contact";
});

app.controller("dataController", function($scope, $http) {
    $scope.daters = [];    
    $scope.getData = function() {
        var req = { 
            method : 'GET', 
            url : '/api/data'
        };
        $http(req).success(function(dater, headers, config)  {
            $scope.daters = dater;
        }).error(function() { 
            console.log('nooo'); 
        });
    };
});

app.controller("aboutController", function($scope) {
    $scope.message = "hi about";   
});

app.factory('authInterceptor', function ($rootScope, $q, $window,$location) {
  return {
    request: function (config) {
      config.headers = config.headers || {};
      if ($window.sessionStorage.token) {
        config.headers.Authorization = 'Bearer ' + $window.sessionStorage.token;
      }
      return config;
    },
    response: function (response) {
      if (response.status === 401) {
          delete $window.sessionStorage.token;
            $location.url('/');
      }
      return response || $q.when(response);
    }
  };
});

app.config(function($routeProvider, $httpProvider) {
  $httpProvider.interceptors.push('authInterceptor');
    $routeProvider
        .when('/', {
            templateUrl : 'temps/home'
          , controller : 'homeController'
        }).when('/register', {
            templateUrl : 'temps/register'
          , controller : 'registerController'
        }).when('/about', {
            templateUrl : 'temps/about'
          , controller : 'aboutController'
        }).when('/login', {
            templateUrl : 'temps/login'
          , controller : 'loginController'
        }).when('/contact', {
            templateUrl : 'temps/contact'
          , controller : 'contactController'
        }).when('/data', {
            templateUrl : 'temps/data'
          , controller : 'dataController'
        }).otherwise({ redirectTo : '/' });
});

