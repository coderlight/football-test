'use strict'

angular.module('mainApp').controller 'TeamsCtrl', [
  'Tournament'
  'Team'
  (Tournament, Team) ->
    vm = this

    vm.tournament = Tournament.current
    vm.team = Team.current

    vm.update = (team) ->
      team = angular.extend({}, vm.team, team)
      new Team(team).update()

    vm
]
