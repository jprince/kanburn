Router.configure(
  layoutTemplate: 'layout'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'
)

Router.map ->
  @route 'admin', path: '/admin'
  @route 'home',
    path: '/'
    waitOn: -> Meteor.subscribe('tickets')
  @route 'release', path: '/admin/release'
  @route 'settings', path: '/admin/settings'
