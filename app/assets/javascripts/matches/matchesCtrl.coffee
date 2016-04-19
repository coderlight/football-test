'use strict'

angular.module('mainApp').controller 'MatchesCtrl', [
  'Match'
  'Round'
  (Match, Round) ->
    vm = this

    vm.matches = Match.all
    vm.teams = Round.current.teams
    vm.countRange = [1, 2, 3, 4, 5]
    vm.count = 1

    vm.default_id = if vm.teams[0] then vm.teams[0].id else null

    vm.match =
      roundId: Round.current.id
      hostTeamId: vm.default_id
      guestTeamId: vm.default_id

    vm.create = ->
      new Match(vm.match).create().then (data) ->
        vm.matches.unshift(data)

    vm.update = ->
      vm.editedMatch.roundId ||= Round.current.id
      vm.editedMatch.update()

    vm

]