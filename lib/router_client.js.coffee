Router.configure(
  layoutTemplate: 'layout'
  yieldTemplates:
    header:
      to: 'header'
    footer:
      to: 'footer'
    filter:
      to: 'filter'
)

Router.map ->
  @route 'home', path: '/'
