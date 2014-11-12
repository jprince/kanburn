Session.setDefault 'selectedSquad', 'Front End'

Tracker.autorun ->
  Meteor.subscribe('release')
  Meteor.subscribe('settings', Session.get('selectedSquad'))
  @ticketSubscriptionHandle = Meteor.subscribe('tickets', Session.get('selectedSquad'))
  Meteor.subscribe('ticketsWithoutComponents')
