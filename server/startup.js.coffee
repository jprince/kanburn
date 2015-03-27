Meteor.startup ->
  Meteor.methods
    removeAllSettings: ->
      Settings.remove({})
    removeAllTickets: ->
      Tickets.remove({})
    removeReleases: ->
      Releases.remove({})

  if Releases.find().count() is 0
    Releases.insert
      squad: 'Front End'
      name: 'FE4.7'
      releaseDate: new Date('03/31/2015')

    Releases.insert
      squad: 'Platform'
      name: 'P4.7'
      releaseDate: new Date('03/31/2015')

    Releases.insert
      squad: 'Platform 5.0'
      name: 'P5.0'
      releaseDate: new Date('06/30/2015')

  squads = ['Front End', 'Platform', 'Platform 5.0']
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
