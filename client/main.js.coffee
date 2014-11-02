squads = ['Front End', 'Platform']
Session.setDefault 'selectedSquad', squads[0]

Template.home.helpers
  completionDate: ->
    selectedSquad = Session.get('selectedSquad') or squads[0]

    openTickets = Tickets.find(
      component: selectedSquad
      points: $gt: 0
      status: $ne: 'Closed'
    ).fetch()

    settings = Settings.find(
      squad: selectedSquad
    ).fetch()[0]

    daysRemaining =
      _(openTickets).where({points: 1}).length * settings.oneStoryPointEstimate +
      _(openTickets).where({points: 2}).length * settings.twoStoryPointEstimate +
      _(openTickets).where({points: 3}).length * settings.threeStoryPointEstimate +
      _(openTickets).where({points: 4}).length * settings.fourStoryPointEstimate +
      _(openTickets).where({points: 5}).length * settings.fiveStoryPointEstimate

    calendarDaysRemaining =
      Math.ceil((daysRemaining * (1 + settings.riskMultiplier))/settings.velocity)

    addWeekdaysToToday = (days) ->
      currentDate = moment()
      while days > 0
        switch currentDate.isoWeekday()
          when 5
            currentDate.add(3, 'd')
            days--
          when 6
            currentDate.add(2, 'd')
          when 7
            currentDate.add(1, 'd')
          else
            currentDate.add(1, 'd')
            days--
      currentDate
    addWeekdaysToToday(calendarDaysRemaining).format('MMMM DD')
  tickets: ->
    Tickets.find(component: Session.get('selectedSquad'))

Template.home.events 'click .btn': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

Template.release.helpers
  editingDoc: ->
    Release.findOne()

Template.settings.helpers
  editingDoc: ->
    selectedSquad = Session.get('selectedSquad') or squads[0]
    Settings.findOne({ squad: selectedSquad })

Template.settings.events 'click .btn': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value
