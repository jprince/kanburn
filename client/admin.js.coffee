Template.releases.helpers
  editingDoc: ->
    getRelease()

Template.settings.helpers
  editingDoc: ->
    getSettings()

Template.releases.events 'change input[type=radio]': (event) ->
  setSelectedSquad(event.currentTarget.value)

Template.settings.events 'change input[type=radio]': (event) ->
  setSelectedSquad(event.currentTarget.value)
