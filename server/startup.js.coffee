Meteor.startup ->
  Meteor.methods
    removeAllSettings: ->
      Settings.remove({})
    removeAllTickets: ->
      Tickets.remove({})
    removeReleases: ->
      Releases.remove({})

  squads = ['Front End', 'Platform', 'Platform 5.0']
  _(squads).each (squad) ->
    release =
      Releases.find(
        squad: squad
      ).fetch()

    if _(release).isEmpty()
      switch squad
        when 'Front End'
          name = 'FE4.7'
          releaseDate = new Date('05/31/2015')
        when 'Platform'
          name = 'P4.7'
          releaseDate = new Date('05/31/2015')
        else
          name = 'P5.0'
          releaseDate = new Date('09/30/2015')

      Releases.insert
        squad: squad
        name: name
        releaseDate: releaseDate

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
