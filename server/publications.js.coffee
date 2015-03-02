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
  baseUrl = 'https://jira.wedostuffwell.com/rest/api/latest/search?jql='
  fields = 'components,customfield_10002,issuetype,labels,priority,status,summary'

  apiRoute = (filterId) ->
    "#{baseUrl}filter=#{filterId}&fields=#{fields}&maxResults=1000"

  jiraFilterMappings =
    'Front End':
      nonBugTickets: '11475'
      bugTickets: '11473'
    'Platform':
      nonBugTickets: '11476'
      bugTickets: '11474'
    withoutComponents: '11472'

  try
    nonBugTickets =
      HTTP.get(
        apiRoute(jiraFilterMappings["#{selectedSquad}"].nonBugTickets),
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    bugTickets =
      HTTP.get(
        apiRoute(jiraFilterMappings["#{selectedSquad}"].bugTickets),
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    ticketsWithoutComponents =
      HTTP.get(
        apiRoute(jiraFilterMappings.withoutComponents),
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    ticketsForSelectedSquad = nonBugTickets.concat(bugTickets).concat(ticketsWithoutComponents)

    formattedTickets = _(ticketsForSelectedSquad).forEach (issue) ->
      doc =
        component: if issue.fields.components[0] then issue.fields.components[0].name else ''
        id: issue.key
        points: issue.fields.customfield_10002 or ''
        priority: issue.fields.priority.name
        labels: issue.fields.labels
        status: issue.fields.status.name
        title: issue.fields.summary
        type: issue.fields.issuetype.name

      self.added 'tickets', Random.id(), doc

    self.ready()

  catch error
    console.log error
