Template.header.helpers
  onHomepage: ->
    Router.current().route.name is 'home'
  releaseDate: ->
    if release = getRelease()
      adjustForTimezone(release.releaseDate).format('MMM DD')
  releaseVersion: ->
    if release = getRelease()
      release.name
