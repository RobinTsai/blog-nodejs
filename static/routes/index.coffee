crypto = require 'crypto'
User = require '../models/user.js'
Post = require '../models/post.js'
Comment = require '../models/comment.js'

checkLogin = (req, res, next) ->
  if not req.session.user
    req.flash('error', 'Not login')
    res.redirect('/login')
  next()

checkNotLogin = (req, res, next) ->
  if req.session.user
    req.flash('error', 'Have logined')
    res.redirect('back')
  next()

router = (app) ->
  app.get '/', (req, res) ->
    page = if req.query.p then parseInt(req.query.p) else 1
    Post.getTen null, page, (err, posts, total) ->
      posts = [] if err
      res.render 'index',
        title: 'Home'
        posts: posts
        page: page
        isFirstPage: (page - 1) is 0
        isLastPage: ((page - 1) * 10 + posts.length) is total
        user: req.session.user
        success: req.flash('success').toString()
        error: req.flash('error').toString()
    # Post.getAll null, (err, posts) ->
    #   posts = [] if err
    #   res.render 'index',
    #     title: 'Home'
    #     posts: posts
    #     user: req.session.user
    #     success: req.flash('success').toString()
    #     error: req.flash('error').toString()

  app.get('/reg', checkNotLogin)
  app.get('/reg', (req, res) ->
    res.render('reg', {
      title: 'Reg',
      user: req.session.user,
      success: req.flash('success').toString(),
      error: req.flash('error').toString()
    })
  )

  app.get('/login', checkNotLogin)
  app.get('/login', (req, res) ->
    res.render('login', {
      title: 'Login',
      user: req.session.user,
      success: req.flash('success').toString(),
      error: req.flash('error').toString()
    })
  )

  app.post('/reg', (req, res) ->
    name = req.body.name
    password = req.body.password
    password_re = req.body['password-repeat']
    if password_re isnt password
      req.flash('error', 'Repete password error')
      return res.redirect('/reg')

    md5 = crypto.createHash('md5')
    password = md5.update(password).digest('hex')

    newUser = new User({
      name: name,
      password: password,
      email: req.body.email
    })

    User.get(newUser.name, (err, user) ->
      if err
        req.flash('error', err)
        return res.redirect('/')
      if user
        req.flash('error', 'User existed.')
        return res.redirect('/reg')

      newUser.save( (err, user) ->
        if err
          req.flash('error', err)
          return req.redirect('/reg')
        req.session.user = user
        req.flash('success', 'Succeed add a user.')
        res.redirect('/')
      )
    )
  )

  app.post '/login', (req, res) ->
    md5 = crypto.createHash('md5')
    password = md5.update(req.body.password).digest('hex')

    User.get req.body.name, (err, user) ->
      if not user
        req.flash('error', 'User not existed!')
        return res.redirect('/login')

      if user.password isnt password
        req.flash('error', 'Error password!')
        return res.redirect('/login')

      req.session.user = user
      req.flash('success', 'Login succeed')
      res.redirect('/')

  app.get '/post', checkLogin
  app.get '/post', (req, res) ->
    res.render 'post',
      title: 'Post'
      user: req.session.user
      success: req.flash('success').toString()
      error: req.flash('error').toString()

  app.post('/post', checkLogin)
  app.post '/post', (req, res) ->
    currentUser = req.session.user
    tags = [req.body.tag1, req.body.tag2, req.body.tag3]
    post = new Post(currentUser.name, req.body.title, tags, req.body.post)
    post.save (err) ->
      if err
        console.log '\x1b[90m'
        console.log err
        console.log '\x1b[39m'
        req.flash('error', err)
        return res.redirect('/')
      req.flash('success', 'post succeed')
      res.redirect('/')

  app.get('/logout', checkLogin)
  app.get('/logout', (req, res) ->
    req.session.user = null
    req.flash('success', 'Logout succeed.')
    res.redirect('/')
  )

  app.get '/upload', checkLogin
  app.get '/upload', (req, res) ->
    res.render 'upload',
      title: '文件上传'
      user: req.session.user
      success: req.flash('success').toString()
      error: req.flash('error').toString()

  app.post '/upload', checkLogin
  app.post '/upload', (req, res) ->
    req.flash 'success', 'Post file succeed'
    res.redirect '/upload'

  app.get '/u/:name', (req, res) ->
    page = if req.query.p then parseInt(req.query.q) else 1
    User.get req.params.name, (err, user) ->
      if not user
        req.flash 'error', 'user not exist'
        return res.redirect '/'
      Post.getTen user.name, page, (err, posts, total) ->
        if err
          req.flash 'error', err
          return res.redirect '/'
        res.render 'user',
          title: user.name
          posts: posts
          page: page
          isFirstPage: (page - 1) is 0
          isLastPage: ((page - 1) * 10 + posts.length) is total
          user: req.session.user
          success: req.flash('success').toString()
          error: req.flash('error').toString()
    # User.get req.params.name, (err, user) ->
    #   if not user
    #     req.flash 'error', 'User not exist'
    #     return res.redirect '/'

    #   Post.getAll user.name, (err, posts) ->
    #     if err
    #       req.flash 'error', err
    #       return res.redirect '/'
    #     res.render 'user',
    #       title: user.name
    #       posts: posts
    #       user: req.session.user
    #       success: req.flash('success').toString()
    #       error: req.flash('error').toString()

  app.get '/u/:name/:day/:title', (req, res) ->
    Post.getOne req.params.name, req.params.day, req.params.title, (err, post) ->
      if err
        req.flash 'error', err
        return redirect '/'
      res.render 'article',
        title: req.params.title
        post: post
        user: req.session.user
        success: req.flash('success').toString()
        error: req.flash('error').toString()

  app.get '/edit/:name/:day/:title', checkLogin
  app.get '/edit/:name/:day/:title', (req, res) ->
    currentUser = req.session.user
    Post.edit currentUser.name, req.params.day, req.params.title, (err, post) ->
      if err
        req.flash 'error', err
        return res.redirect 'back'
      res.render 'edit',
        title: 'Edit'
        post: post
        user: req.session.user
        success: req.flash('success').toString()
        error: req.flash('error').toString()

  app.post '/edit/:name/:day/:title', checkLogin
  app.post '/edit/:name/:day/:title', (req, res) ->
    currentUser = req.session.user
    Post.update currentUser.name, req.params.day, req.params.title, req.body.post, (err) ->
      url = encodeURI('/u/' + req.params.name + '/' + req.params.day + '/' + req.params.title)
      if err
        req.flash 'error', err
        return res.redirect url
      req.flash 'success', 'Edit successfully'
      res.redirect url

  app.get '/remove/:name/:day/:title', checkLogin
  app.get '/remove/:name/:day/:title', (req, res) ->
    currentUser = req.session.user
    Post.remove currentUser.name, req.params.day, req.params.title, (err) ->
      if err
        req.flash 'error', err
        return res.redirect 'back'
      req.flash 'success', 'Delete successfully'
      res.redirect '/'

  app.post '/u/:name/:day/:title', (req, res) ->
    date = new Date()
    time = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate() + '' + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' + date.getMinutes() else date.getMinutes())
    comment =
      name: req.body.name
      email: req.body.email
      website: req.body.website
      time: time
      content: req.body.content
    newCom = new Comment(req.params.name, req.params.day, req.params.title, JSON.stringify(comment))

    console.log newCom
    newCom.save (err) ->
      if err
        req.flash 'error', err
        return res.redirect 'back'
      req.flash 'success', 'comment successfully'
      res.redirect 'back'
      console.log 'save over'

  app.get '/archive', (req, res) ->
    Post.getArchive (err, posts) ->
      if err
        req.flash 'error', err
        return res.redirect '/'
      res.render 'archive',
        title: '存档'
        posts: posts
        user: req.session.user
        success: req.flash('success').toString()
        error: req.flash('error').toString()

  app.get '/tags', (req, res) ->
    Post.getTags (err, posts) ->
      if err
        req.flash 'error', err
        return res.redirect '/'
      res.render 'tags',
        title: 'Tags',
        posts: posts
        user: req.session.user
        success: req.flash('success').toString()
        error: req.flash('error').toString()

module.exports = router
