Router.configure(
  layoutTemplate: 'layout'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'
)

Router.map ->
  @route 'home', path: '/'
  @route 'admin', path: '/admin'
