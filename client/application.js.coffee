Session.setDefault 'selectedSquad', 'Web'

Tracker.autorun ->
  Meteor.subscribe('releases', Session.get('selectedSquad'))
  Meteor.subscribe('settings', Session.get('selectedSquad'))
  @ticketSubscriptionHandle = Meteor.subscribe('tickets', Session.get('selectedSquad'))
