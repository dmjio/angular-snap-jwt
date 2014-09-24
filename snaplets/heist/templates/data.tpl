<div class="jumbotron text-center">
  <h1>Data Page</h1>

  <p>{{ message }}</p>
  <button ng-click="getData()">Get Data</button>
  <ul ng-repeat="d in daters">
    <li>{{ d }}</li>
  </ul>
</div>
