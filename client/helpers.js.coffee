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
  bugs = getAllBugs()
  unless _(bugs).isEmpty()
    drawDonutChart(getGroupedData(bugs, 'priority'), 'bugs-by-priority', 0.40, 283, true)
    drawDonutChart(getGroupedData(bugs, 'status'), 'bugs-by-status', 0.40, 283, true)

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
    { type: 'Bug' },
    { fields: { 'points': 0 } }
  ).fetch()

@getClosedBugs = ->
  Tickets.find(
    status: $in: ['Closed', 'Deployed']
    type: 'Bug'
  ).fetch()

@getClosedTickets = ->
  Tickets.find(
    points: $gt: 0
    status: $in: ['Closed', 'Deployed']
  ).fetch()

@getCriticalBugs = ->
  Tickets.find(
    { priority: 'Critical', type: 'Bug'},
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
    while days > 0
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

@getGroupedData = (data, grouping) ->
  groupedData = _(data).groupBy(grouping)
  _(groupedData).map((value, key) -> { label: key, value: Math.round(value.length) })

@getOpenBugs = ->
  Tickets.find(
    status: $nin: ['Closed', 'Deployed']
    type: 'Bug'
  ).fetch()

@getOpenTicketsWithEstimates = ->
  Tickets.find(
    points: $gt: 0
    status: $nin: ['Closed', 'Deployed']
  ).fetch()

@getRelease = ->
  Release.findOne() or {}

@getSettings = ->
  Settings.find(
    squad: Session.get('selectedSquad')
  ).fetch()[0]

@getSquads = ->
  [
    { name: 'Front End', activeClass: isActiveSquad('Front End') },
    { name: 'Platform', activeClass: isActiveSquad('Platform') }
  ]

@getTicketsOnHold = ->
  Tickets.find(
    { title: /\bhold/i },
    { fields: { 'component': 0 } }
  ).fetch()

@getTicketsWithoutComponents = ->
  Tickets.find(
    { component: '' },
    { fields: { 'component': 0 } }
  ).fetch()

@getTicketsWithoutEstimates = ->
  Tickets.find(
    { points: $in: ['', 0] },
    { fields: { 'points': 0 } }
  ).fetch()

@isActiveSquad = (squad) ->
  if Session.get('selectedSquad') is squad then 'active' else ''
