components = ['Front End', 'Platform']
Session.setDefault "components", components

Template.filter.helpers
  components: ->
    components
  checked: ->
    checked: true if @toString() in Session.get('components')

Template.filter.events 'click input[type=checkbox]': (event, template) ->
  checkedCheckboxes = template.$('input:checked')
  selectedComponents = _(checkedCheckboxes).map (checkbox) ->
    checkbox.value

  Session.set 'components', selectedComponents

Template.home.helpers
  tickets: ->
    Tickets.find(
      { component: $in: Session.get('components') }
    )
