closedTicketStatuses = ['Review', 'Closed', 'Deployed']

@adjustForTimezone = (date) ->
  dateObject = moment(date)
  timezoneOffset = dateObject.zone()

  dateObject.add(timezoneOffset, 'm')

@calculateDays = (nonBugTickets, bugTickets) ->
  settings = getSettings()

  unless settings is undefined
    pointOptions = [1..13]

    daysByPoints =
      for point in pointOptions
        _(nonBugTickets).where({points: point}).length * convertPointsToDays(point)

    bugEstimates = bugTickets.length * settings.bugEstimate

    daysByPoints.reduce(((daysSoFar, option) ->
      daysSoFar + option), 0) + bugEstimates

@chartColors = ->
  ['#74C449', '#12baae', '#127bb7', '#7c12b5', '#b2115c', '#af5011', '#aaad11']

@convertPointsToDays = (points) ->
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

@drawCharts = ->
  allBugs = getAllBugs()
  unless _(allBugs).isEmpty()
    drawDonutChart(getGroupedData(allBugs, 'status'), 'bugs-by-status', 0.40, 283, true)

  openBugs = getOpenBugs()
  unless _(openBugs).isEmpty()
    drawDonutChart(getGroupedData(openBugs, 'priority'), 'open-bugs-by-priority', 0.40, 283, true)

  daysGroupedByStatus = getDaysGroupedByStatus()
  unless _(daysGroupedByStatus).isEmpty()
    drawDonutChart(daysGroupedByStatus, 'work-chart', 0.65, 283, false)

  openTicketsWithEstimates = getOpenTicketsWithEstimates()
  unless _(openTicketsWithEstimates).isEmpty()
    drawDonutChart(
      getGroupedData(openTicketsWithEstimates, 'points'),
      'tickets-by-points',
      0.40,
      283,
      true
    )

@drawDonutChart = (data, domId, ratio, size, showLegend) ->
  nv.addGraph ->
    chart = nv.models.pieChart()
      .color(chartColors())
      .donut(true)
      .donutRatio(ratio)
      .height(size)
      .showLabels(false)
      .showLegend(showLegend)
      .tooltipContent((key, y, e) -> "<h3> #{key} </h3> <p> #{Math.round(y)} </p>")
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

@getAllBugs = ->
  Tickets.find(
    type: 'Bug'
    { fields: { 'points': 0 } }
  ).fetch()

@getClosedBugs = ->
  Tickets.find(
    status: $in: closedTicketStatuses
    type: 'Bug'
  ).fetch()

@getClosedTickets = ->
  Tickets.find(
    points: $gt: 0
    status: $in: closedTicketStatuses
  ).fetch()

@getCriticalBugs = ->
  Tickets.find(
    priority: 'Critical'
    status: $nin: closedTicketStatuses
    type: 'Bug'
    { fields: { 'points': 0 } }
  ).fetch()

@getDaysGroupedByStatus = ->
  settings = getSettings()
  unless settings is undefined
    groupedData = _(Tickets.find().fetch()).groupBy('status')
    aggregatedData = _(groupedData).map((value, key) ->
      label: key
      value: value.reduce(((daysSoFar, ticket) ->
        daysSoFar +
          if ticket.type is 'Bug'
            settings.bugEstimate
          else
            (convertPointsToDays(ticket.points) or 0)
      ), 0)
    )
    aggregatedData

@getEstimatedCompletionDate = ->
  settings = getSettings()
  unless settings is undefined
    daysRemaining = calculateDays(getOpenTicketsWithEstimates(), getOpenBugs())
    totalEffort = (daysRemaining * (1 + settings.riskMultiplier)) + settings.holidayTime
    calendarDaysRemaining = Math.ceil(totalEffort/settings.velocity)

  addWeekdaysToToday = (days) ->
    currentDate = moment()
    while days >= 0
      switch currentDate.isoWeekday()
        when 6
          currentDate.add(2, 'd')
          days-- if days is 0
        when 7
          currentDate.add(1, 'd')
        else
          currentDate.add(1, 'd')
          days--
    currentDate

  addWeekdaysToToday(calendarDaysRemaining)

@getGroupedData = (data, grouping) ->
  groupedData = _(data).groupBy(grouping)
  _(groupedData).map((value, key) -> { label: key, value: Math.round(value.length) })

@getOpenBugs = ->
  Tickets.find(
    status: $nin: closedTicketStatuses
    type: 'Bug'
  ).fetch()

@getOpenTicketsWithEstimates = ->
  Tickets.find(
    labels: $ne: 'ExcludeFromKanburn'
    points: $gt: 0
    status: $nin: closedTicketStatuses
  ).fetch()

@getRelease = ->
  Releases.findOne({ squad: Session.get('selectedSquad') })

@getSettings = ->
  Settings.findOne({ squad: Session.get('selectedSquad') })

@getSquads = ->
  [
    { name: 'Front End', activeClass: isActiveSquad('Front End') },
    { name: 'Platform', activeClass: isActiveSquad('Platform') },
    { name: 'Platform 5.0', activeClass: isActiveSquad('Platform 5.0') }
  ]

@getTicketsOnHold = ->
  Tickets.find(
    title: /\bhold/i
    { fields: { 'component': 0 } }
  ).fetch()

@getTicketsWithoutComponents = ->
  Tickets.find(
    component: ''
    status: $nin: closedTicketStatuses
    { fields: { 'component': 0 } }
  ).fetch()

@getTicketsWithoutEstimates = ->
  Tickets.find(
    points: $in: ['', 0]
    type: $ne: 'Bug'
    { fields: { 'points': 0 } }
  ).fetch()

@isActiveSquad = (squad) ->
  if Session.get('selectedSquad') is squad then 'active' else ''

@setSelectedSquad = (squad) ->
  Session.set 'selectedSquad', squad
