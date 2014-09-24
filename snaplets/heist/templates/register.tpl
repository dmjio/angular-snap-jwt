<div class="jumbotron text-center">
<h2>Register</h2>
<form ng-submit="register()">
  <label for="user">Email</label>
  <input id="user" name="user" ng-model="user.username" type="text" required />
  <label for="pass">Password</label>
  <input id="pass" name="pass" ng-model="user.password" type="password" required />
  <input type="submit" value="Register" />
</form>
</div>
