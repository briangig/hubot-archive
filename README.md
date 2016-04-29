# hubot-archive

A hubot script that archives every conversation the hubot sees.

See [`src/archive.coffee`](src/archive.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-archive --save`

Then add **hubot-archive** to your `external-scripts.json`:

```json
[
  "hubot-archive"
]
```

## Sample Interaction

```
user1>> hubot channel count <channel> - Retuns the number of messages logged in the database for a particular channel
user1>> hubot channel mentions <phrase> - Returns logged messages containing the specified phrase
```
