UI.registerHelper('daysRemaining', (openTickets, settings) ->
    _(openTickets).where({points: 1}).length * settings.oneStoryPointEstimate +
    _(openTickets).where({points: 2}).length * settings.twoStoryPointEstimate +
    _(openTickets).where({points: 3}).length * settings.threeStoryPointEstimate +
    _(openTickets).where({points: 4}).length * settings.fourStoryPointEstimate +
    _(openTickets).where({points: 5}).length * settings.fiveStoryPointEstimate
)
