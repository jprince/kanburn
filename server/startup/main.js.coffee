Meteor.startup ->
  Meteor.methods removeAllTickets: ->
    Tickets.remove({})
