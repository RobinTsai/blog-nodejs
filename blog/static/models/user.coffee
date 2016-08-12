
mongodb = require('./db')

User = (user) ->
  this.name = user.name
  this.password = user.password
  this.email = user.email

module.exports = User

User.prototype.save = (callback) ->
  user =
    name: this.name
    password: this.password
    email: this.email

  mongodb.open (err, db) ->
    return callback err if err
    db.collection 'users', (err, collection) ->
      if err
        mongodb.close()
        return callback err

      collection.insert(user, {
        safe: true
      }, (err, user) ->
        mongodb.close()
        return callback err if err
        callback null, user[0]
      )

User.get = (name, callback) ->
  mongodb.open (err, db) ->
    return callback err if err

    db.collection 'users', (err, collection) ->
      if err
        mongodb.close()
        return callback err

      collection.findOne({
        name: name
      }, (err, user) ->
        mongodb.close()
        return callback err if err
        callback null, user
      )
