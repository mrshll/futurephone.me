NSQClient = require 'nsq-client'
Util = require "util"

nsq = new NSQClient debug: true

nsq.on "error", (err) ->
  console.log "ERROR " + Util.inspect(err)

nsq.on "debug", (event) ->
  console.log "DEBUG " + Util.inspect(event)

TOPIC = process.env.TOPIC

# Query db for notifications to dispatch
mongoose = require './db'
Message = require './models/message'

# Poll database for messages that need to be enqueued
setInterval (->
  messages = Message.find()
  _.each messages, (message) ->
    nsq.publish TOPIC,
      message: message
), 1000

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing client connections"
  console.log "Press CTL-C again to force quit"
  client.close ->
    process.exit()
