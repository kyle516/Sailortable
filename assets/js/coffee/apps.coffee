###

  Sailortable by Kyle Ideta
  Version 1.0

###


'use strict'


# Utilities
addEmptyCell = (source, amount, start, period) ->
  for i in [0...amount]
    source.splice(start, 0, {period: period ? -1})


replaceCell = (source, target, start, end, period) ->
  arr = source.slice(start, end)
  source.splice(start, end)

  addEmptyCell(arr, 2, 0)
  addEmptyCell(source, 1, start, period)

  target.push(
    elements: arr
  )

getRandom = (min, max) ->
  Math.floor Math.random() * max + min



# Configures
conRoute = ($routeProvider) ->
  $routeProvider
    .when('/',
      templateUrl: './assets/template/table.html'
      controller: 'ctrTable'
    )
    .when('/element/:number',
      templateUrl: './assets/template/single.html'
      controller: 'ctrSingle'
      controllerAs: 'single'
    )
    .otherwise(
      redirectTo: '/'
    );



# Models
mdElements = ($resource, dataUrl) ->
  $resource(dataUrl.elements)

mdDescription = ($resource, dataUrl) ->
  $resource(dataUrl.freebase, {key: 'AIzaSyBj37kE9cDSOIA2REC53mbz2ostGty-ojY'})



# Directives
sailorTable = () ->
  controller: 'ctrSailorTable as sailortable'

tableElement = () ->
  templateUrl: './assets/template/table-element.html'
  controller: 'ctrTableElement as item'



# Services
srvElement = ->
  getType: (element) ->
    if !element?
      return 'no-type'

    switch(element.category)
      when 'Alkali Metal'
        return 'type-a'
      when 'Alkaline Earth Metal'
        return 'type-b'
      when 'Transition Metal'
        return 'type-c'
      when 'Halogen'
        return 'type-d'
      when 'Noble Gas'
        return 'type-e'
      when 'Nonmetal'
        return 'type-f'
      when 'Metalloid'
        return 'type-g'
      when 'Base Metal'
        return 'type-h'
      when 'Lanthanoid'
        return 'type-i'
      when 'Actinoid'
        return 'type-j'
      when 'Unknown'
        return 'type-k'





# Controllers
ctrSailorTable = ($scope, $interval, $route, mdElements, srvElement) ->
  mdElements.get().$promise.then((res) =>
    @res = res
    @allElem = []
    @mode = 'S'
    @ready = no

    for set in @res.data
      period = set.period
      elements = set.elements

      # Make pure array of elements for elements' individual views.
      Array.prototype.push.apply(@allElem, elements)

      # Insert random pos for shuffling effect.
      for element in elements
        element.pos =
          left: getRandom(-500, 700) + 'px'
          top: getRandom(-400, 800) + 'px'

      # Insert dummy cells for building periodic table.
      switch(period)
        when 1
          addEmptyCell(elements, 16, 1, period)
        when 2, 3
          addEmptyCell(elements, 10, 2, period)
        when 6, 7
          replaceCell(elements, @res.data, 2, 15, period)
  )


  $scope.$on '$routeChangeSuccess', (event, next, current) ->
    # Shuffling intro effect
    if !current?
      $interval((->
          for set in $scope.sailortable.res.data
            for element in set.elements
              element.pos =
                left: 0
                top: 0

          $scope.sailortable.ready = yes
        ),
        2000
      )

    # Set background color scheme
    $scope.setColor = () ->
      srvElement.getType(next?.scope.element)


ctrTable = ($scope) ->



ctrTableElement = ($scope, srvElement) ->
  $scope.setCellColor = () ->
    srvElement.getType($scope.element)


ctrSingle = ($scope, $routeParams, mdDescription) ->
  $scope.element = $scope.sailortable.allElem[$routeParams.number - 1]
  $scope.shell = ['K','L','M','N','O','P','Q']

  # Grab freebase data
  if(!$scope.element.description?)
    mdDescription.get({id: $scope.element.freebase, filter: '/common/topic/description'}).$promise.then((res) =>
      $scope.element.description = res.property['/common/topic/description'].values[0].value;
    )






# Inject modules
angular
  .module('sailorTable', ['ngResource', 'ngRoute', 'ngAnimate'])
  .constant('dataUrl',
    elements: 'assets/data/elements.json'
    freebase: 'https://www.googleapis.com/freebase/v1/topic/:id'
  )
  .config(conRoute)
  .factory('mdElements', mdElements)
  .factory('mdDescription', mdDescription)
  .factory('srvElement', srvElement)
  .directive('sailorTable', sailorTable)
  .directive('tableElement', tableElement)
  .controller('ctrSailorTable', ['$scope', '$interval', '$route', 'mdElements', 'srvElement', ctrSailorTable])
  .controller('ctrSingle', ['$scope', '$routeParams', 'mdDescription', ctrSingle])
  .controller('ctrTable', ['$scope', ctrTable])
  .controller('ctrTableElement', ['$scope', 'srvElement', ctrTableElement])



# Inject apps
angular.module('app', ['sailorTable'])