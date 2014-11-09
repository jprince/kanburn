# Shared variables and functions
squads = ['Front End', 'Platform']
Session.setDefault 'selectedSquad', squads[0]

calculateDays = (openTickets) ->
  settings = getSettings()

  unless settings is undefined
    pointOptions = [1..13]

    daysByPoints =
      for point in pointOptions
        _(openTickets).where({points: point}).length * convertPointsToDays(point)

    daysByPoints.reduce(((daysSoFar, option) ->
      daysSoFar + option), 0)

chartColors = ->
  ['#74C449', '#12baae', '#127bb7', '#7c12b5', '#b2115c', '#af5011', '#aaad11']

convertPointsToDays = (points) ->
  if Session.get('selectedSquad') is 'Front End'
    settings = getSettings()

    switch points
      when 1 then settings.oneStoryPointEstimate
      when 2 then settings.twoStoryPointEstimate
      when 3 then settings.threeStoryPointEstimate
      when 4 then settings.fourStoryPointEstimate
      when 5 then settings.fiveStoryPointEstimate
      else 0
  else points

drawDonutChart = (data, domId, ratio, size, showLegend) ->
  nv.addGraph ->
    chart = nv.models.pieChart()
      .color(chartColors())
      .donut(true)
      .donutRatio(ratio)
      .height(size)
      .showLabels(false)
      .showLegend(showLegend)
      .tooltipContent((key, y, e) -> "<h3> #{key} </h3> <p> #{y} </p>")
      .width(size)
      .x((d) -> d.label)
      .y((d) -> d.value)

      d3.select("##{domId} svg")
        .datum(data)
        .transition()
        .duration(350)
        .style
          'height': size
          'width': size
        .call chart
    chart

getAllBugs = ->
  Tickets.find(
    { component: Session.get('selectedSquad'), type: 'Bug' },
    { fields: { 'points': 0 } }
  ).fetch()

getAllTickets = ->
  Tickets.find(
    component: Session.get('selectedSquad')
  ).fetch()

getBugsGroupedBy = (grouping) ->
  groupedData = _(getAllBugs()).groupBy(grouping)
  aggregatedData = _(groupedData).map((value, key) -> { label: key, value: Math.round(value.length) })

getClosedTickets = ->
  Tickets.find(
    component: Session.get('selectedSquad')
    points: $gt: 0
    status: $in: ['Closed', 'Deployed']
  ).fetch()

getCriticalBugs = ->
  Tickets.find(
    { component: Session.get('selectedSquad'), priority: 'Critical', type: 'Bug'},
    { fields: { 'points': 0 } }
  ).fetch()

getEstimatedCompletionDate = ->
  settings = getSettings()
  unless settings is undefined
    daysRemaining = calculateDays(getOpenTickets(), settings)
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

getPointsGroupedByStatus = ->
  groupedData = _(getAllTickets()).groupBy('status')
  aggregatedData = _(groupedData).map((value, key) ->
    label: key
    value: value.reduce(((daysSoFar, ticket) ->
      daysSoFar + (convertPointsToDays(ticket.points) or 0)), 0)
  )
  aggregatedData

getRelease = ->
  Release.findOne() or {}

getSettings = ->
  Settings.find(
    squad: Session.get('selectedSquad')
  ).fetch()[0]

getTicketsWithoutComponents = ->
  Tickets.find(
    { component: '' },
    { fields: { 'component': 0 } }
  ).fetch()

getTicketsWithoutEstimates = ->
  Tickets.find(
    { component: Session.get('selectedSquad'), points: '' },
    { fields: { 'points': 0 } }
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

  daysCompleted: ->
    calculateDays(getClosedTickets())

  daysRemaining: ->
    calculateDays(getOpenTickets())

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
  drawDonutChart(getBugsGroupedBy('priority'), 'bugs-by-priority', 0.55, 283, true)
  drawDonutChart(getBugsGroupedBy('status'), 'bugs-by-status', 0.55, 283, true)
  drawDonutChart(getPointsGroupedByStatus(), 'work-chart', 0.65, 283, false)

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
  drawDonutChart(getBugsGroupedBy('priority'), 'bugs-by-priority', 0.55, 283, true)
  drawDonutChart(getBugsGroupedBy('status'), 'bugs-by-status', 0.55, 283, true)
  drawDonutChart(getPointsGroupedByStatus(), 'work-chart', 0.65, 283, false)
