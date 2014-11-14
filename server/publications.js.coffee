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

    bug_ticket_response = HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=11455&maxResults=1000',
      headers:
        "Authorization": authorizationHeader
    ).data.issues

    tickets_without_components_response = HTTP.get('https://jira.wedostuffwell.com/rest/api/latest/search?jql=filter=11472&maxResults=1000',
      headers:
        "Authorization": authorizationHeader
    ).data.issues

    tickets_with_components_response = non_bug_ticket_response.concat(bug_ticket_response)

    filteredResponse = _(tickets_with_components_response.map (issue) ->
      if issue.fields.components[0].name is selectedSquad
        issue
      ).compact()

    aggregate_response = filteredResponse.concat(tickets_without_components_response)

    formattedResponse = _(aggregate_response).forEach (issue) ->
      doc =
        component: if issue.fields.components[0] then  issue.fields.components[0].name else ''
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
