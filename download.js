var fs = require('fs')
var os = require('os')
var path = require('path')
var request = require('request')
var mkdirp = require('mkdirp')

module.exports = function (url, opts, target, cb) {
  var tmpDir = './tmp'
  var retries = opts.retries || 3
  tryDl()
  function tryDl () {
    retries--
    if (retries <= 0) return cb(new Error('Max retries exceeded ' + url))
    fs.stat(target, function (err, stat) {
      if (!err) return cb() // skip if exists already
      var req = request(url, opts)
      req.on('error', function (err) {
        setTimeout(tryDl, 5000) // wait 5 seconds in case server is having a momentary hiccup
      })
      // write to tmpdir and rename when successful to avoid corrupted half-dl
      var tmp = tmpDir + '/goes-16-tmp-' + Date.now()
      req.on('response', function (resp) {
        if (resp.statusCode !== 200) return cb(new Error('Status ' + resp.statusCode + ' ' + url))
        resp.pipe(fs.createWriteStream(tmp)).on('finish', function () {
          mkdirp(path.dirname(target), function (err) {
            if (err) return cb(err)
            fs.rename(tmp, target, function (err) {
              if (err) return cb(err)
              console.error(url)
              fs.unlink(tmp, cb)
            })
          })
        })
      })
    })
  }
}
