Meteor.startup ->
  Meteor.methods removeAllTickets: ->
    Tickets.remove({})

  if Release.find().count() is 0
    Release.insert
      name: '4.5'
      releaseDate: new Date('12/31/2014')
