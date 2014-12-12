Template.home.helpers
  completionDate: ->
    getEstimatedCompletionDate().format('MMMM DD')

  criticalBugs: ->
    getCriticalBugs()

  daysCompleted: ->
    calculateDays(getClosedTickets(), getClosedBugs())

  daysRemaining: ->
    calculateDays(getOpenTicketsWithEstimates(), getOpenBugs())

  isLoading: ->
    Session.get('loading')

  onHold: ->
    getTicketsOnHold()

  onSchedule: ->
    estimatedCompletionDate = getEstimatedCompletionDate().startOf('day')
    releaseDate = adjustForTimezone(getRelease().releaseDate)

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

Template.home.events 'change input[type=radio]': (event) ->
  Session.set 'loading', true
  Session.set 'selectedSquad', event.currentTarget.value

Template.home.events 'slide.bs.carousel': (event) ->
  nextCardIsFirstCard = ($(event.relatedTarget).find('#work-remaining')).length > 0

  if nextCardIsFirstCard
    Session.set(
      'selectedSquad',
      if Session.get('selectedSquad') is 'Front End' then 'Platform' else 'Front End'
    )

Tracker.autorun ->
  Session.set 'loading', true
  if ticketSubscriptionHandle.ready()
    Session.set 'loading', false
    drawCharts()
