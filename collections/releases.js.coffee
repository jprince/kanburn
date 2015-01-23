@Releases = new Meteor.Collection('releases')

Releases.attachSchema(new SimpleSchema(
  squad:
    type: String
    max: 50
  name:
    type: String
    label: "Current release"
    max: 20
  releaseDate:
    type: Date
))
