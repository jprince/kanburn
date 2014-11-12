Meteor.publish 'release', ->
  Release.find()

Meteor.publish 'settings', (selectedSquad) ->
  Settings.find(
    squad: selectedSquad
  )

Meteor.publish 'tickets', (selectedSquad) ->
  Tickets.find(
    component: selectedSquad
  )

Meteor.publish 'ticketsWithoutComponents', ->
  Tickets.find(
    { component: '' },
  )
