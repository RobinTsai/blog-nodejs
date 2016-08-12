mongodb = require './db'

Comment = (name, day, title, comment) ->
  this.name = name
  this.day = day
  this.title = title
  this.comment = comment

module.exports = Comment

Comment.prototype.save = (callback) ->
  name = this.name
  day = this.day
  title = this.title
  comment = this.comment

  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback
      collection.update
        name: name
        'time.day': day
        title: title
      ,
        $push:
          comments: comment
      , (err) ->
        mongodb.close()
        reutrn callback err if err
        callback null
