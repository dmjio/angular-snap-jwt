<!-- index.html -->
<!DOCTYPE html>
<html ng-app="app">
  <head>
    <link rel="stylesheet" href="https://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://netdna.bootstrapcdn.com/font-awesome/4.0.0/css/font-awesome.css" />
    <base href="/">
  </head>
  <body ng-controller="homeController">
    <header>
      <nav class="navbar navbar-default">
        <div class="container">
          <div class="navbar-header">
            <a class="navbar-brand" href="/">Angular
              Routing Example</a>
          </div>
          <ul class="nav navbar-nav navbar-right">
            <li><a href="#"><i class="fa fa-home"></i> Home</a></li>
            <li><a href="#about"><i class="fa fa-shield"></i> About</a></li>
            <li><a href="#contact"><i class="fa fa-comment"></i> Contact</a></li>
            <li><a href="#login"><i class="fa fa-book"></i> Login</a></li>
            <li><a href="#register"><i class="fa fa-bell"></i> Register</a></li>
            <li><a href="#data"><i class="fa fa-ban"></i> Data</a></li>
            <li><a href="#logout" ng-click="logout()"><i class="fa fa-frown-o"></i> Logout</a></li>
          </ul>
        </div>
      </nav>
    </header>
    <div id="main" >
      <div ng-view>
      </div>
    </div>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.25/angular.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.25/angular-route.js"></script>
    <script src="static/js/app.js"></script>
  </body>
</html>
