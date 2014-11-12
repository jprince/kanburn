Session.setDefault 'selectedSquad', 'Front End'

Tracker.autorun ->
  Meteor.subscribe('release')
  Meteor.subscribe('settings', Session.get('selectedSquad'))
  Meteor.subscribe('tickets', Session.get('selectedSquad'))
  Meteor.subscribe('ticketsWithoutComponents')
