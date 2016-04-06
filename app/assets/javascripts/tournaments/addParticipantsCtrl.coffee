'use strict'

angular.module('mainApp').controller 'AddParticipantsCtrl', [
  'Tournament'
  '$uibModalInstance'
  'users'
  (Tournament, $uibModalInstance, users) ->
    vm = this

    vm.participants = angular.copy(Tournament.current.users)
    vm.users = users

    vm.moveUser = (index, from, to) ->
      to.push(from[index])
      from.splice(index, 1)

    vm.close = ->
      $uibModalInstance.close(vm.participants)

    vm.cancel = ->
      $uibModalInstance.dismiss('cancel')
    vm
]