Session.setDefault 'selectedSquad', 'Front End'

Tracker.autorun ->
  Meteor.subscribe('releases', Session.get('selectedSquad'))
  Meteor.subscribe('settings', Session.get('selectedSquad'))
  @ticketSubscriptionHandle = Meteor.subscribe('tickets', Session.get('selectedSquad'))
