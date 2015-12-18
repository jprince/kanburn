Meteor.startup ->
  Meteor.methods
    removeAllSettings: ->
      Settings.remove({})
    removeAllTickets: ->
      Tickets.remove({})
    removeReleases: ->
      Releases.remove({})

  squads = ['Web', 'Platform', 'Platform 5.0', 'Measures']
  _(squads).each (squad) ->
    release =
      Releases.find(
        squad: squad
      ).fetch()

    if _(release).isEmpty()
      switch squad
        when 'Web'
          name = 'FE4.9'
          releaseDate = new Date('07/31/2015')
        when 'Platform'
          name = 'P4.9'
          releaseDate = new Date('07/31/2015')
        when 'Platform 5.0'
          name = 'P5.0'
          releaseDate = new Date('09/30/2015')
        else
          name = 'MRC1.1'
          releaseDate = new Date('07/31/2015')

      console.log "Inserting release for #{ squad }"
      Releases.insert
        squad: squad
        name: name
        releaseDate: releaseDate

    settings =
      Settings.find(
        squad: squad
      ).fetch()

    if _(settings).isEmpty()
      console.log "Inserting settings for #{ squad }"
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
