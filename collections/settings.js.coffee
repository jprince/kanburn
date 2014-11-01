@Settings = new Meteor.Collection('settings')

Settings.attachSchema(new SimpleSchema(
  squad:
    type: String
    max: 50
  velocity:
    type: Number
    label: "Ave velocity (man days/day)"
    min: 0
    decimal: true
  riskMultiplier:
    type: Number
    label: "Risk multiplier"
    min: 0
    max: 1
    decimal: true
  oneStoryPointEstimate:
    type: Number
    label: "1 story point estimate (days)"
    min: 0
    decimal: true
  twoStoryPointEstimate:
    type: Number
    label: "2 story point estimate (days)"
    min: 0
    decimal: true
  threeStoryPointEstimate:
    type: Number
    label: "3 story point estimate (days)"
    min: 0
    decimal: true
  fourStoryPointEstimate:
    type: Number
    label: "4 story point estimate (days)"
    min: 0
    decimal: true
  fiveStoryPointEstimate:
    type: Number
    label: "5 story point estimate (days)"
    min: 0
    decimal: true
))
