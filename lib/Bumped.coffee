'use strict'

async   = require 'neo-async'
Semver  = require './Bumped.semver'
Config  = require './Bumped.config'
Logger  = require './Bumped.logger'
DEFAULT = require './Bumped.default'
MSG     = require './Bumped.messages'

module.exports = class Bumped

  constructor: (opts = {}) ->
    process.chdir opts.cwd if opts.cwd?
    @config = new Config this
    @semver = new Semver this
    @logger = new Logger opts.logger
    this

  init: (opts, cb) =>
    args = DEFAULT.args arguments

    tasks = [
      (next) => @config.autodetect args.opts, next
      (next) => @config.save args.opts, next
      (next) => @semver.sync args.opts, next
    ]

    async.waterfall tasks, (err, result) =>
      @logger.errorHandler err, args.cb
      if args.opts.outputMessage
        @logger.success MSG.CONFIG_CREATED()
        @logger.success MSG.CURRENT_VERSION @_version
      args.cb()
