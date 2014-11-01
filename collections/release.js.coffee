@Release = new Meteor.Collection('release')

Release.attachSchema(new SimpleSchema(
  name:
    type: String
    label: "Current release"
    max: 20
  releaseDate:
    type: Date
))
