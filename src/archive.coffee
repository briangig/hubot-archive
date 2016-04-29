# Description:
#   Allows Hubot to record slack conversations in elastic search and query them
#
# Commands:
#   hubot channel count <channel> - Retuns the number of messages logged in the database for a particular channel
#   hubot channel mentions <phrase> - Returns logged messages containing the specified phrase
#
# Configuration:
#   ELASTICSEARCH_HOST hostname of the elastic search cluster
#   ELASTICSEARCH_PORT port of the elastic search cluster
#   ELASTICSEARCH_INDEX elastic search index to used for archiving
#
# Notes:
#   Use at your own risk
#
# Author:
#   Fabian Bull <fabian.bull@datameer.com>

module.exports = (robot) ->

  ELASTICSEARCH_HOST = "http://localhost"
  if(process.env.ELASTICSEARCH_HOST?)
    ELASTICSEARCH_HOST = process.env.ELASTICSEARCH_HOST

  ELASTICSEARCH_PORT = 9200
  if(process.env.ELASTICSEARCH_PORT?)
     ELASTICSEARCH_PORT = process.env.ELASTICSEARCH_PORT

  ELASTICSEARCH_INDEX = "archive"
  if(process.env.ELASTICSEARCH_INDEX?)
    ELASTICSEARCH_INDEX = process.env.ELASTICSEARCH_INDEX

  ELASTICSEARCH_CLUSTER = "#{ELASTICSEARCH_HOST}:#{ELASTICSEARCH_PORT}"

  # listen to everything
  robot.hear /.*/i, (res) ->
    robot.http("#{ELASTICSEARCH_CLUSTER}/#{ELASTICSEARCH_INDEX}/#{res.message.room}/#{res.message.id}?pretty")
    .header('Content-Type', 'application/json')
    .header('Accept', 'application/json')
    .put(JSON.stringify(res.message)) (err, response, body) ->
      console.log("Logged message from #{res.message.user.name} in #{res.message.room} with id #{res.message.id}.")


  # ask hubot how many messages are recorded for a particular channel
  robot.respond /channel count (.*)/i, (res) ->
    query = JSON.stringify({
      "query": {
        "match": {
          "room": "#{res.match[1]}"
        }
      }
    })

    robot.http("#{ELASTICSEARCH_CLUSTER}/#{ELASTICSEARCH_INDEX}/_search?pretty")
      .header('Content-Type', 'application/json')
      .header('Accept', 'application/json')
      .post(query) (err, response, body) ->
        parsedBody = JSON.parse(body)
        res.send(parsedBody.hits.total)
        console.log("Channel count command fired for channel #{res.match[1]}.")

  # ask hubot to for messages containing a certain string
  robot.respond /channel mentions (.*)/i, (res) ->
    query = JSON.stringify({
      "_source": ["rawText"],
      "query": {
        "match_phrase": {
          "rawText": "#{res.match[1]}"
        }
      }
    })

    robot.http("#{ELASTICSEARCH_CLUSTER}/#{ELASTICSEARCH_INDEX}/_search?pretty")
      .header('Content-Type', 'application/json')
      .header('Accept', 'application/json')
      .post(query) (err, response, body) ->
        JSON.parse(body).hits.hits.map((hit) => res.send(hit._source.rawText));
        console.log("Channel mentions command fired for string #{res.match[1]}.")