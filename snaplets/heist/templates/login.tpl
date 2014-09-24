<div class="jumbotron text-center">
<h2>Login</h2>
<form ng-submit="login()">
  <label for="username">Email</label>
  <input id="username" name="username" ng-model="user.username" type="text" required />
  <label for="password">Password</label>
  <input id="password" name="password" ng-model="user.password" type="password" required />
  <input type="submit" value="Login" />
</form>
</div>
