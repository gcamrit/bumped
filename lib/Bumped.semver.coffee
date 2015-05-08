'use strict'

semver = require 'semver'
async     = require 'neo-async'
path      = require 'path'
os      = require 'os'
fs      = require 'fs-extra'

module.exports = class Semver

  constructor: (bumped) ->
    @bumped = bumped

  sync: (cb) =>
    async.compose(@max, @versions) (err, max) =>
      @_version = max
      cb()

  versions: (cb) =>
    async.map @bumped.config.files, (file, next) ->
      version = require(path.resolve(file)).version
      next(null, version)
    , cb

  max: (versions, cb) ->
    initial = versions.shift()
    async.reduce versions, initial, (max, version, next) ->
      max = version if semver.gt version, max
      next(null, max)
    , cb

  increment: (release, cb) ->
    newVersion = semver.inc @version(), release
    @version newVersion
    async.each @bumped.config.files, @save, (err) =>
      @bumped.errorHandler err, cb
      @bumped.logger.success "Created version #{@version()}"
      cb?()

  save: (file, cb) =>
    filepath = path.resolve file
    file = require filepath
    file.version = @version()
    fileoutput = JSON.stringify(file, null, 2) + os.EOL
    fs.writeFile filepath, fileoutput, encoding: 'utf8', cb

  version: (newVersion) ->
    return @_version if arguments.length is 0
    @_version = newVersion
