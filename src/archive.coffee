
# Description:
#   Everything hubot sees is archived to local storage.
#
# Commands:
# Notes:
#   Use at your own risk
#
# Based on hubot-archive by
#   Fabian Bull <fabian.bull@datameer.com>
# 
# Author:
#   Brian Giguere <briangig@gmail.com>


module.exports = (robot) ->
  fs = require 'fs'


  startLogging = ->
    console.log "Started logging"
    robot.catchAll (res) ->
      fs.mkdir logFilePath(res), (error) ->
        console.log "Folder likely exists: #{error}" if error
      fs.appendFile logFileName(res), formatMessage(res), (error) ->
        console.log "Could not log message: #{error}" if error
  logFilePath = (res) ->
    "E:/path/#{res.message.room}/"
  logFileName = (res) ->
    today = new Date  
    dd = today.getDate()  
    mm = today.getMonth() + 1  
    yyyy = today.getFullYear()  
    if dd < 10  
      dd = '0' + dd  
    if mm < 10  
      mm = '0' + mm
    today = mm + '-' + dd + '-' + yyyy
    safe_room_name = "#{res.message.room}".replace /[^a-z0-9]/ig, ''
    "E:/path/#{res.message.room}/#{today}.txt"
  	formatMessage = (res) ->
    "[#{new Date().toLocaleTimeString('en-US', { hour12: false })}] //**#{res.message.user.real_name}:**// #{res.message.text}\\\\ \n"

  startLogging()
