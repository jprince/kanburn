@Release = new Meteor.Collection('release')

Release.attachSchema(new SimpleSchema(
  name:
    type: String
    label: "Current Release"
    max: 20
  releaseDate:
    type: Date
    label: "Release Date"
))
