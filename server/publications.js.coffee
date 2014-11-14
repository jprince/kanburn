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

  try
    nonBugTickets =
      HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=10805&maxResults=1000',
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    bugTickets =
      HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=11455&maxResults=1000',
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    ticketsWithoutComponents =
      HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=11472&maxResults=1000',
        headers:
          "Authorization": authorizationHeader
      ).data.issues

    ticketsWithComponents = nonBugTickets.concat(bugTickets)

    ticketsForSelectedSquad = _(ticketsWithComponents.map (issue) ->
      if issue.fields.components[0].name is selectedSquad
        issue
      ).compact().concat(ticketsWithoutComponents)

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
