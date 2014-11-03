# Shared variables and functions
squads = ['Front End', 'Platform']
Session.setDefault 'selectedSquad', squads[0]

calculateDaysRemaining = (openTickets, settings) ->
  unless settings is undefined
    _(openTickets).where({points: 1}).length * settings.oneStoryPointEstimate +
    _(openTickets).where({points: 2}).length * settings.twoStoryPointEstimate +
    _(openTickets).where({points: 3}).length * settings.threeStoryPointEstimate +
    _(openTickets).where({points: 4}).length * settings.fourStoryPointEstimate +
    _(openTickets).where({points: 5}).length * settings.fiveStoryPointEstimate

drawDonutChart = (data) ->
  nv.addGraph ->
    chart = nv.models.pieChart()
      .x((d) -> d.label)
      .y((d) -> d.value)
      .showLabels(true)
      .labelThreshold(.05)
      .labelType("percent")
      .donut(true)
      .donutRatio(0.35)

      d3.select("#bug-chart svg")
        .datum(data)
        .transition()
        .duration(350)
        .call chart
    chart

getBugsGroupedByPriority = (squad) ->
  bugs = Tickets.find(
    component: squad
    type: 'Bug'
  ).fetch()

  groupedData = _(bugs).groupBy('priority')
  aggregatedData = _(groupedData).map((value, key) -> { label: key, value: Math.round(value.length) })

getEstimatedCompletionDate = (squad, settings) ->
  unless settings is undefined
    daysRemaining = calculateDaysRemaining(openTicketsForSquad(squad), settings)
    calendarDaysRemaining =
      Math.ceil((daysRemaining * (1 + settings.riskMultiplier))/settings.velocity)

  addWeekdaysToToday = (days) ->
    currentDate = moment()
    while days > 1
      switch currentDate.isoWeekday()
        when 6
          currentDate.add(2, 'd')
        when 7
          currentDate.add(1, 'd')
        else
          currentDate.add(1, 'd')
          days--
    currentDate
  addWeekdaysToToday(calendarDaysRemaining)

getRelease = ->
  Release.findOne() or {}

getSettingsForSquad = (squad) ->
  Settings.find(
    squad: squad
  ).fetch()[0]

openTicketsForSquad = (squad) ->
  Tickets.find(
    component: squad
    points: $gt: 0
    status: $nin: ['Closed', 'Deployed']
  ).fetch()

# Home
Template.home.helpers
  completionDate: ->
    selectedSquad = Session.get('selectedSquad')
    settings = getSettingsForSquad(selectedSquad)
    getEstimatedCompletionDate(selectedSquad, settings).format('MMMM DD')

  criticalBugs: ->
    Tickets.find(
      component: Session.get('selectedSquad')
      priority: 'Critical'
      type: 'Bug'
    )

  daysRemaining: ->
    selectedSquad = Session.get('selectedSquad')
    calculateDaysRemaining(openTicketsForSquad(selectedSquad), getSettingsForSquad(selectedSquad))

  onSchedule: ->
    selectedSquad = Session.get('selectedSquad')
    settings = getSettingsForSquad(selectedSquad)
    estimatedCompletionDate = getEstimatedCompletionDate(selectedSquad, settings)

    releaseDate = getRelease().releaseDate
    estimatedCompletionDate <= releaseDate

  withoutComponent: ->
    Tickets.find(component: '')

  withoutEstimate: ->
    Tickets.find(
      component: Session.get('selectedSquad')
      points: ''
    )

Template.home.rendered = ->
  aggregatedData = getBugsGroupedByPriority(Session.get('selectedSquad'))
  drawDonutChart(aggregatedData)

Template.home.events 'click .btn': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

# Admin - Release
Template.release.helpers
  editingDoc: ->
    getRelease()

# Admin - Settings
Template.settings.helpers
  editingDoc: ->
    selectedSquad = Session.get('selectedSquad') or squads[0]
    Settings.findOne({ squad: selectedSquad })

Template.settings.events 'click .btn': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

# Watch Dependencies
Tracker.autorun ->
  selectedSquad = Session.get('selectedSquad')
  updatedAggregateBugData = getBugsGroupedByPriority(selectedSquad)
  drawDonutChart(updatedAggregateBugData)
