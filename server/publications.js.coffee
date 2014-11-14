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
    non_bug_ticket_response = HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=10805&maxResults=1000',
      headers:
        "Authorization": authorizationHeader
    ).data.issues

    bug_ticket_response = HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=11455',
      headers:
        "Authorization": authorizationHeader
    ).data.issues

    response = non_bug_ticket_response.concat(bug_ticket_response)

    console.log non_bug_ticket_response.length

    filteredResponse = _(response.map (issue) ->
      if issue.fields.components[0].name is selectedSquad
        issue
      ).compact()

    formattedResponse = _(filteredResponse).forEach (issue) ->
      doc =
        component: issue.fields.components[0].name
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

Meteor.publish 'ticketsWithoutComponents', ->
  Tickets.find(
    { component: '' },
  )
