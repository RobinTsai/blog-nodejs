mongodb = require('./db')
MongoId = require('mongodb').ObjectID
markdown = require('markdown').markdown

Post = (name, title, tags, post) ->
  this.name = name
  this.title = title
  this.tags = tags
  this.post = post

module.exports = Post

Post.prototype.save = (callback) ->
  date = new Date()
  time =
    date: date,
    year: date.getFullYear()
    month: date.getFullYear() + '-' + (date.getMonth() + 1)
    day: date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate()
    minute: date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate() + ' ' + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' + date.getMinutes() else date.getMinutes())


  post =
    name: this.name
    time: time
    title: this.title
    tags: this.tags
    post: this.post
    comments: []

  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback(err)
      collection.insert post, {
        safe: false
      }, (err) ->
        mongodb.close()
        return callback err  if err
        callback null

Post.getAll = (name, callback) ->
  mongodb.open( (err, db) ->
    return callback err if err
    db.collection('posts', (err, collection) ->
      if err
        mongodb.close()
        return callback(err)
      query = {}
      query.name = name if name
      collection.find(query).sort({
        time: -1
      }).toArray((err, docs) ->
        mongodb.close()
        return callback err if err
        docs.forEach (doc) ->
          doc.post = markdown.toHTML(doc.post)

        callback null, docs
      )
    )
  )

Post.getOne =  (name, day, title, callback) ->
  mongodb.open (err, db) ->
    return callback(err) if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback(err)
      collection.findOne
        name: name
        'time.day': day
        title: title
      , (err, doc) ->
        return callback(err) if err
        if doc
          doc.post = markdown.toHTML doc.post
          console.log '\x1b[90mGet comments:'
          doc.comments.forEach (comment) ->
            comment = JSON.parse(comment)
            comment.content = markdown.toHTML comment.content
            console.log comment
            console.log ''
          console.log 'Comments over\x1b[39m'
        callback null, doc

Post.edit = (name, day, title, callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback(err)
      collection.findOne
        name: name
        'time.day': day
        title: title
      , (err, doc) ->
        console.log '\x1B[90m'
        console.log name + ' ' + day + ' ' + title
        console.log '\x1B[39m'
        mongodb.close()
        return callback err if err
        callback null, doc

Post.update = (name, day, title, post, callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback err
      collection.update
        name: name
        'time.day': day
        title: title
      ,
        $set:
          post: post
      , (err) ->
        mongodb.close()
        return callback err if err
        callback null

Post.remove = (name, day, title, callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback err
      collection.remove
        name: name
        'time.day': day
        title: title
      , (err, doc) ->
        mongodb.close()
        return callback err if err
        callback null

Post.getTen = (name, page, callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback err
      query = {}
      if name
        query.name = name
      collection.count query, (err, total) ->
        collection.find query,
          skip: (page - 1) * 10
          limit: 10
        .sort
          time: -1
        .toArray (err, docs) ->
          mongodb.close()
          return callback err if err
          docs.forEach (doc) ->
            doc.post = markdown.toHTML doc.post
          callback null, docs, total

Post.getArchive = (callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback err
      collection.find {},
        name: 1
        time: 1
        title: 1
      .sort
        time: -1
      .toArray (err, docs) ->
        mongodb.close()
        return callback err if err
        callback null, docs

Post.getTags = (callback) ->
  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'posts', (err, collection) ->
      if err
        mongodb.close()
        return callback err
      collection.distinct 'tags', (err, docs) ->
        mongodb.close()
        return callback err if err
        callback null, docs
