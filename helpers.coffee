if typeof define isnt 'function' then define = require('amdefine')(module)
define [
  'moment'
  './models/user'
], (moment, User) ->
  class Helpers
    ROOT_URL: process.env.ROOT_URL || 'http://localhost:7076'
    DEBUG: process.env.APP_ENV is 'debug'

    # Queue topics
    CONVERTER_TOPIC: process.env.NSQ_CONVERTER_TOPIC
    CALLER_TOPIC: process.env.NSQ_CALLER_TOPIC

    calculateFutureDelivery: (unit, magnitude) ->
      moment().add unit, parseInt(magnitude)

    debug: (msg) ->
      console.log msg if process.env.APP_ENV is 'debug'

    ###### MIDDLEWARE

    # Custom middleware to output route in debug mode
    outputRequestRoute: (req, res, next) =>
      @debug "#{ req.originalUrl } #{ req.method }"
      next()

    # Custom middleware to hydrate request with current user
    hydrateRequestWithUser: (req, res, next) ->
      if req.session and req.session.userID
        User.findById req.session.userID, (err, user) ->
          if not err and user
            req.user = user
            next()
          else
            next new Error("Could not restore User from Session.")
      else
        next()

    userRequired: (req, res, next) ->
      # TODO: Authenticate
      if req.user then next() else next new Error 'Not Logged In'

  module.exports = new Helpers
