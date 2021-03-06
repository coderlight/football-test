'use strict'

angular.module('mainApp').directive 'myCurrentTournamentLink', [
  'Tournament'
  (Tournament) ->
    restrict: 'A'
    link: (scope, element, attrs, ctrl, transcludeFn) ->
      scope.$watch((-> Tournament.current), (newVal, oldVal) ->
        if newVal && newVal.id
          attrs.$set('href', '#/tournaments/' + Tournament.current.id + attrs.myCurrentTournamentLink)
          element.html(Tournament.current.toTitle()) if attrs.setName)
]
