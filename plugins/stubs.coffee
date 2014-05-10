template = require 'gulp-template'

module.exports = ( warlock ) ->
  warlock.flow 'stubs-to-build',
    source: [ '<%= globs.source.stubs %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    tasks: [ 'webapp-build' ]
    merge: 'flow::styles-to-build::90'

  .add( 50, 'stubs-generate', template )

