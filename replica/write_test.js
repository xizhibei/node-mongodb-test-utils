'use strict';

var crypto = require('crypto');
var _ = require('lodash');
var Promise = require('bluebird');

var User = require('./test_user_model');

program
  .version('0.0.1')
  .option('-n, --number <n>', 'Documents number to be writen', 100000)
  .parse(process.argv);

var total = program.number;

Promise.map(_.range(total / 1000), function(i) {
    var data = _.times(1000, function(j) {
        return {
            _id: i * 1000 + j,
            name: crypto.randomBytes(32).toString('hex'),
            desc: crypto.randomBytes(64).toString('hex'),
        }
    })
    return User.create(data);
}, {
    concurrency: 1
}).then(function() {
    console.log('done');
    process.exit();
})