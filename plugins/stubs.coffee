wrap = require 'gulp-wrap'

module.exports = (warlock) ->
  defaultTplPath = warlock.file.joinPath __dirname, "../templates/stub.js.tpl"

  tplWrap = (options) ->
    options.src = options.tpl
    options.src = defaultTplPath if options.src is "default"
    delete options.tpl
    wrap(options)

  warlock.flow 'angular-stubs-to-generate',
    source: [ '<%= globs.source.stubs %>' ]
    source_options:
      base: "<%= paths.source_app %>"
    tasks: [ 'webapp-build' ]
    merge: 'flow::scripts-to-build::20'

  .add(80, 'angular-stubs-generate', tplWrap)