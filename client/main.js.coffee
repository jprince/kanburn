components = ['Front End', 'Platform']
Session.setDefault "components", components

Template.home.helpers
  components: ->
    components
  checked: ->
    checked: true if @toString() in Session.get('components')
  tickets: ->
    Tickets.find(
      { component: $in: Session.get('components') }
    )

Template.home.events 'click input[type=checkbox]': (event, template) ->
  checkedCheckboxes = template.$('input:checked')
  selectedComponents = _(checkedCheckboxes).map (checkbox) ->
    checkbox.value

  Session.set 'components', selectedComponents
