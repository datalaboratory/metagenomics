app.directive 'substanceFilter', ($document, $rootScope) ->
  restrict: 'E'
  replace: true
  templateUrl: 'directives/substance-filter.html'
  scope:
    data: '='
  link: ($scope, $element, $attrs) ->
    $scope.isListShown = false
    $scope.dataset = []

    _.keys $scope.data.resistances
      .forEach (key) ->
        $scope.dataset.push
          title: key
          value: key

        return if $scope.data.resistances[key].length < 2

        $scope.data.resistances[key].forEach (s) ->
          $scope.dataset.push
            title: s
            value: s
            parent: key
          return
        return

    $scope.substanceFilterValue = $scope.dataset[0]
    defaultSubstanceFilterValue = $scope.dataset[0]
    isSubstanceChangedFromOutside = false

    clickHandler = (event) ->
      return if $element.find(event.target).length

      $scope.isListShown = false
      $scope.$apply()
      $document.unbind 'click', clickHandler
      return

    $scope.toggleList = ->
      $scope.isListShown = not $scope.isListShown

      if $scope.isListShown
        $document.bind 'click', clickHandler
      else
        $document.unbind 'click', clickHandler
      return

    getItem = (item) ->
      item = _.find($scope.dataset, 'value': item) if typeof item is 'string'
      item

    $scope.isItemSelected = (item) ->
      $scope.substanceFilterValue.value is getItem(item).value

    $scope.selectItem = (item) ->
      $scope.substanceFilterValue = getItem item
      $scope.isListShown = false
      return

    prepareInfoBlockData = ->
      infoLink = undefined
      database = undefined

      if $scope.substanceFilterValue.value.indexOf('ABX') is -1
        substance = _.find $scope.data.substances, 'name': $scope.substanceFilterValue.value
        infoLink = substance['infoLink']
        database = if substance['resistance'].indexOf('ABX') is -1 then 'BacMet' else 'CARD'

      eventData =
        resistance: $scope.substanceFilterValue.parent
        substance: $scope.substanceFilterValue.value
        isSubstanceChangedFromOutside: isSubstanceChangedFromOutside
        infoLink: infoLink
        database: database

      eventData

    # Events →
    $scope.$watch 'substanceFilterValue', ->
      $rootScope.$broadcast 'filters.substanceChanged', prepareInfoBlockData()

      if isSubstanceChangedFromOutside
        isSubstanceChangedFromOutside = false
      else
        defaultSubstanceFilterValue = $scope.substanceFilterValue
      return

    # → Events
    $scope.$on 'heatmap.substanceChanged', (event, eventData) ->
      isSubstanceChangedFromOutside = true unless isSubstanceChangedFromOutside

      if eventData
        $scope.substanceFilterValue = _.find $scope.dataset, 'value': eventData
      else
        $scope.substanceFilterValue = defaultSubstanceFilterValue
      return

    $scope.$on 'heatmap.defaultSubstanceChanged', (event) ->
      $rootScope.$broadcast 'filters.substanceChanged', prepareInfoBlockData()

      defaultSubstanceFilterValue = $scope.substanceFilterValue
      return

    return
