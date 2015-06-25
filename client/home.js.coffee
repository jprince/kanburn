isFirstLoad = true

pauseCarousel = ->
  Meteor.setTimeout (->
    $('#carousel').carousel('pause')
  ), 200

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
    if release = getRelease()
      releaseDate = adjustForTimezone(release.releaseDate)
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
  pauseCarousel()
  Session.set 'loading', true
  setSelectedSquad(event.currentTarget.value)

Template.home.events 'slide.bs.carousel': (event) ->
  nextCardIsFirstCard = ($(event.relatedTarget).find('#work-remaining')).length > 0

  if nextCardIsFirstCard
    pauseCarousel()
    Session.set(
      'selectedSquad',
      switch Session.get('selectedSquad')
        when 'Front End'
          'Platform'
        when 'Platform'
          'Platform 5.0'
        when 'Platform 5.0'
          'Measures'
        else
          'Front End'
      )

Tracker.autorun ->
  Session.set 'loading', true
  if ticketSubscriptionHandle.ready()
    if isFirstLoad
      $('#carousel').carousel(interval: '20000')
      isFirstLoad = false
    else
      $('#carousel').carousel(pause: 'hover')
    drawCharts()
    Session.set 'loading', false
