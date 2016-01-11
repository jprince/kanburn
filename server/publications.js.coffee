Meteor.publish 'releases', (selectedSquad) ->
  Releases.find(
    squad: selectedSquad
  )

Meteor.publish 'settings', (selectedSquad) ->
  Settings.find(
    squad: selectedSquad
  )

Meteor.publish 'tickets', (selectedSquad) ->
  self = @
  username = process.env.JIRA_USERNAME
  password = process.env.JIRA_PASSWORD
  headerValue = CryptoJS.enc.Utf8.parse("#{username}:#{password}")
  authorizationHeader = "Basic #{CryptoJS.enc.Base64.stringify(headerValue)}"
  baseUrl = 'https://jira.arcadiasolutions.com/rest/api/latest/search?jql='
  fields = 'components,customfield_10002,issuetype,labels,priority,status,summary'

  fetchTickets = (filterId) ->
    HTTP.get(
      "#{baseUrl}filter=#{filterId}&fields=#{fields}&maxResults=1000",
      headers:
        "Authorization": authorizationHeader
    ).data.issues


  jiraFilterMappings =
    'Web': '11475'
    'Platform': '11476'
    'Platform 5.0': '12029'
    'Measures': '12462'
    'Without Component': '11472'

  try
    tickets = fetchTickets(jiraFilterMappings["#{selectedSquad}"])
    ticketsWithoutComponents = fetchTickets(jiraFilterMappings['Without Component'])
    ticketsForSelectedSquad = tickets.concat(ticketsWithoutComponents)

    formattedTickets = _(ticketsForSelectedSquad).forEach (issue) ->
      doc =
        component: if issue.fields.components[0] then issue.fields.components[0].name else ''
        id: issue.key
        labels: issue.fields.labels
        points: issue.fields.customfield_10002 or ''
        priority: issue.fields.priority.name
        status: issue.fields.status.name
        title: issue.fields.summary
        type: issue.fields.issuetype.name

      self.added 'tickets', Random.id(), doc

    self.ready()

  catch error
    console.log error
