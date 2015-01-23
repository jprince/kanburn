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
  @route 'home', path: '/'
  @route 'releases', path: '/admin/releases'
  @route 'settings', path: '/admin/settings'
