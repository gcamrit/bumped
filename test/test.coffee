path    = require 'path'
should  = require 'should'
fs      = require 'fs-extra'
Bumped  = require '../lib/Bumped'
pkg     = require '../package.json'

describe 'Bumped ::', ->

  describe 'core', ->

    before ->
      src = path.resolve(__dirname, 'fixtures/sample_directory')
      dest = path.resolve(__dirname, 'sample_directory')
      fs.copySync(src, dest)
      @bumped = new Bumped(cwd: dest, logger: {color: true})

    after ->
      fs.removeSync("#{process.cwd()}/.#{pkg.name}rc")

    describe 'core ::', ->

      it 'initialize a configuration file', (done) ->
        @bumped.init ->
          config = fs.readFileSync('.bumpedrc', encoding: 'utf8')
          config = JSON.parse(config)
          config.files.length.should.be.equal 2
          done()

    describe 'semver ::', ->

      it 'sync correctly the version between the files', ->
        @bumped.semver.version (version) ->
          version.should.be.equal('0.2.0')

      it 'try to release a new version that is not valid', (done) ->
        @bumped.semver.release version:null, (err, version) ->
          (err?).should.be.equal true
          done()

      it 'try to release a new version that is not valid string', (done) ->
        @bumped.semver.release version:'1.0', (err, version) ->
          (err?).should.be.equal true
          done()

      it 'try to release a new version that is a valid string but is not greater', (done) ->
        @bumped.semver.release version:'0.1.0', (err, version) ->
          (err?).should.be.equal true
          done()

      it 'releases a new version that is a valid based in a number', (done) ->
        @bumped.semver.release version:'1.0.0', (err, version) ->
          (err?).should.be.equal false
          version.should.be.equal('1.0.0')
          require('./sample_directory/bower.json').version.should.be.equal('1.0.0')
          done()

      it 'release a new version that is valid based in a semver keyword', (done) ->
        @bumped.semver.release version:'minor', (err, version) ->
          (err?).should.be.equal false
          version.should.be.equal('1.1.0')
          require('./sample_directory/bower.json').version.should.be.equal('1.1.0')
          done()

    describe 'config ::', ->
      it 'just add a file', (done) ->
        @bumped.config.add
          file: 'test.json'
          outputMessage: true
        , (err, files) ->
          files.length.should.be.equal 3
          done()

      it 'try to add a file that is already added', (done) ->
        @bumped.config.add
          file: 'test.json'
          outputMessage: true
        , (err, files) ->
          (err?).should.be.equal true
          files.length.should.be.equal 3
          done()

      it 'prevent add a file that doesn\'t exist in the directory', (done) ->
        @bumped.config.add
          file: 'testing.json'
          detect: true
          outputMessage: true
        , (err, files) ->
          (err?).should.be.equal true
          files.length.should.be.equal 3
          done()

      it 'add a file that exist in the directory and then save it', (done) ->
        @bumped.config.add
          file: 'component.json'
          detect: true
          outputMessage: true
          save: true
        , (err, files) ->
          (err?).should.be.equal false
          files.length.should.be.equal 4
          config = fs.readFileSync('.bumpedrc', encoding: 'utf8')
          config = JSON.parse(config)
          config.files.length.should.be.equal 4
          done()
