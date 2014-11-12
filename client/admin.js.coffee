Template.release.helpers
  editingDoc: ->
    getRelease()

Template.settings.helpers
  editingDoc: ->
    Settings.findOne({ squad: Session.get('selectedSquad') })

Template.settings.events 'change input[type=radio]': (event) ->
  Session.set 'selectedSquad', event.currentTarget.value
