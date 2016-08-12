express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
settings = require './settings'
session = require 'express-session'
MongoStore = require('connect-mongo')(session)
flash = require 'connect-flash'
multer = require 'multer'

routes = require './routes/index'

app = express()

app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'ejs')

app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))
app.use(cookieParser())

app.use(session({
  secret: settings.cookieSecret,
  key: settings.db,
  cookie: {
    maxAge: 1000 * 60 * 60 * 24 * 30
  },
  store: new MongoStore({
    db: settings.db,
    host: settings.host,
    port: settings.port
  }),
  resave: false,
  saveUninitialized: false
}))

app.use(flash())
app.use(express.static(path.join(__dirname, 'public')))

app.use multer({
  dest: './public/images/'
  rename: (fieldname, filename) ->
    return filename
})
routes(app)

app.use( (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)
)

if app.get('env') is 'development'
  app.use (err, req, res, next) ->
    res.status err.status || 500
    res.render 'error', {
      message: err.message,
      error: err
    }

app.use( (err, req, res, next) ->
  res.status(err.status || 500)
  res.render('error', {
    message: err.message,
    error: {}
  })
)

module.exports = app
