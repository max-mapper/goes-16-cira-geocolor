var moment = require('moment-timezone')
var date = process.argv[2]
date = `${date.slice(0, 8)}T${date.slice(8, 14)}`
console.error(date)
console.log(moment(date).tz('America/Los_Angeles').format("dddd, MMMM Do YYYY, h:mma z"))