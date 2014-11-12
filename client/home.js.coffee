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

_.extend Template.home,
  created: ->
    @squadToggleInterval = Meteor.setInterval(->
      if Session.get('selectedSquad') is 'Front End'
        Session.set 'selectedSquad', 'Platform'
      else
        Session.set 'selectedSquad', 'Front End'
    , 50000)

  destroyed: ->
    Meteor.clearInterval @squadToggleInterval

Template.home.events 'change input[type=radio]': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value

Tracker.autorun ->
  if ticketSubscriptionHandle.ready()
    drawCharts()
