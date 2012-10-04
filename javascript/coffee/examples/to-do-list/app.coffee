#Setup express.js
global.express = require 'express'
global.app = express()
require "#{__dirname}/src/configuration"

#Set up the Database
require "#{__dirname}/src/models/database"

#Require the Todo model and controller
require "#{__dirname}/src/models/todo"
require "#{__dirname}/src/controllers/todos_controller"

#Set up a routing for our home page
require "#{__dirname}/src/controllers/home_controller"

#Start server
app.listen(3000)
console.log "Express server listening on port %d in %s mode", 3000, app.settings.env
