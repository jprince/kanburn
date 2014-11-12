Meteor.startup ->
  Meteor.methods
    removeAllSettings: ->
      Settings.remove({})
    removeAllTickets: ->
      Tickets.remove({})
    removeRelease: ->
      Release.remove({})

  if Release.find().count() is 0
    Release.insert
      name: '4.5'
      releaseDate: new Date('12/31/2014')

  squads = ['Platform', 'Front End']
  _(squads).each (squad) ->
    settings =
      Settings.find(
        squad: squad
      ).fetch()

    if _(settings).isEmpty()
      Settings.insert
        squad: squad
        velocity: 0
        riskMultiplier: 0
        oneStoryPointEstimate: 0
        twoStoryPointEstimate: 0
        threeStoryPointEstimate: 0
        fourStoryPointEstimate: 0
        fiveStoryPointEstimate: 0
        bugEstimate: 0
        holidayTime: 0
