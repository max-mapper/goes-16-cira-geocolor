var fs = require('fs')
var os = require('os')
var request = require('request')
var mkdirp = require('mkdirp')

module.exports = function (url, opts, target, cb) {
  var tmpDir = os.tmpdir()
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
      var tmp = tmpdir + '/goes-16-tmp-' + Date.now()
      req.pipe(fs.createWriteStream(tmp)).on('finish', function () {
        mkdirp(path.dirname(target), function (err) {
          if (err) return cb(err)
          fs.rename(tmp, target, cb)            
        })
      })
    })
  }
}
