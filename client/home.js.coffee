Template.home.helpers
  completionDate: ->
    getEstimatedCompletionDate().format('MMMM DD')

  criticalBugs: ->
    getCriticalBugs()

  daysCompleted: ->
    calculateDays(getClosedTickets(), getClosedBugs())

  daysRemaining: ->
    calculateDays(getOpenTicketsWithEstimates(), getOpenBugs())

  onHold: ->
    getTicketsOnHold()

  onSchedule: ->
    estimatedCompletionDate = getEstimatedCompletionDate().startOf('day')
    releaseDate = moment(getRelease().releaseDate).startOf('day')

    estimatedCompletionDate <= releaseDate

  thereAreBugs: ->
    not _(getAllBugs()).isEmpty()

  thereAreCriticalBugs: ->
    not _(getCriticalBugs()).isEmpty()

  thereAreTicketsOnHold: ->
    not _(getTicketsOnHold()).isEmpty()

  thereAreTicketsWithoutComponents: ->
    not _(getTicketsWithoutComponents()).isEmpty()

  thereAreTicketsWithoutEstimates: ->
    not _(getTicketsWithoutEstimates()).isEmpty()

  withoutComponent: ->
    getTicketsWithoutComponents()

  withoutEstimate: ->
    getTicketsWithoutEstimates()

Template.home.rendered = ->
  drawCharts()
  Session.set 'sliderRotations', 0

Template.home.events 'change input[type=radio]': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

Template.home.events 'slide.bs.carousel': (event) ->
  Session.set 'sliderRotations', Session.get('sliderRotations') + 1

  if Session.get('sliderRotations') % 5 is 0
    Session.set(
      'selectedSquad',
      if Session.get('selectedSquad') is 'Front End' then 'Platform' else 'Front End'
    )

Tracker.autorun ->
  if ticketSubscriptionHandle.ready()
    drawCharts()
