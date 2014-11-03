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

getAllBugs = ->
  Tickets.find(
    component: Session.get('selectedSquad')
    type: 'Bug'
  ).fetch()

getBugsGroupedByPriority = ->
  groupedData = _(getAllBugs()).groupBy('priority')
  aggregatedData = _(groupedData).map((value, key) -> { label: key, value: Math.round(value.length) })

getCriticalBugs = ->
  Tickets.find(
    component: Session.get('selectedSquad')
    priority: 'Critical'
    type: 'Bug'
  ).fetch()

getEstimatedCompletionDate = ->
  settings = getSettings()
  unless settings is undefined
    daysRemaining = calculateDaysRemaining(getOpenTickets(), settings)
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

getOpenTickets = ->
  Tickets.find(
    component: Session.get('selectedSquad')
    points: $gt: 0
    status: $nin: ['Closed', 'Deployed']
  ).fetch()

getRelease = ->
  Release.findOne() or {}

getSettings = ->
  Settings.find(
    squad: Session.get('selectedSquad')
  ).fetch()[0]

getTicketsWithoutComponents = ->
  Tickets.find(component: '').fetch()

getTicketsWithoutEstimates = ->
  Tickets.find(
    component: Session.get('selectedSquad')
    points: ''
  ).fetch()

#Header
Template.header.helpers
  onHomepage: ->
    Router.current().route.name is 'home'

# Home
Template.home.helpers
  completionDate: ->
    getEstimatedCompletionDate().format('MMMM DD')

  criticalBugs: ->
    getCriticalBugs()

  daysRemaining: ->
    calculateDaysRemaining(getOpenTickets(), getSettings())

  onSchedule: ->
    estimatedCompletionDate = getEstimatedCompletionDate()
    releaseDate = getRelease().releaseDate

    estimatedCompletionDate <= releaseDate

  thereAreBugs: ->
    not _(getAllBugs()).isEmpty()

  thereAreCriticalBugs: ->
    not _(getCriticalBugs()).isEmpty()

  thereAreTicketsWithoutComponents: ->
    not _(getTicketsWithoutComponents()).isEmpty()

  thereAreTicketsWithoutEstimates: ->
    not _(getTicketsWithoutEstimates()).isEmpty()

  withoutComponent: ->
    getTicketsWithoutComponents()

  withoutEstimate: ->
    getTicketsWithoutEstimates()

Template.home.rendered = ->
  drawDonutChart(getBugsGroupedByPriority())

Template.home.events 'change input[type=radio]': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

# Admin - Release
Template.release.helpers
  editingDoc: ->
    getRelease()

# Admin - Settings
Template.settings.helpers
  editingDoc: ->
    Settings.findOne({ squad: Session.get('selectedSquad') })

Template.settings.events 'change input[type=radio]': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

# Watch Dependencies
Tracker.autorun ->
  drawDonutChart(getBugsGroupedByPriority())
