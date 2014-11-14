Meteor.publish 'release', ->
  Release.find()

Meteor.publish 'settings', (selectedSquad) ->
  Settings.find(
    squad: selectedSquad
  )

Meteor.publish 'tickets', (selectedSquad) ->
  self = this
  username = process.env.JIRA_USERNAME
  password = process.env.JIRA_PASSWORD
  headerValue = CryptoJS.enc.Utf8.parse("#{username}:#{password}")
  authorizationHeader = "Basic #{CryptoJS.enc.Base64.stringify(headerValue)}"

  apiRoute = (filterId) ->
    "https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=#{filterId}&maxResults=1000"

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
        type: issue.fields.issuetype.name
        title: issue.fields.summary
        priority: issue.fields.priority.name
        status: issue.fields.status.name
        points: issue.fields.customfield_10002 or ''

      self.added 'tickets', Random.id(), doc

    self.ready()

  catch error
    console.log error
