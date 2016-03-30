#!/usr/bin/env node

'use strict'

var mongoose = require('mongoose');
var program = require('commander');
var Promise = require('bluebird');
var _ = require('lodash');

var User = require('./test_user_model');

program
  .version('0.0.1')
  .option('-c, --count <n>', 'Circle', 4)
  .option('-t, --timeout <n>', 'Timeout', 4)
  .option('-n, --number <n>', 'Documents number to be read', 100000)
  .option('-e, --event <s>', 'Mongo event to be listen, open|fullsetup|all', 'open')
  .parse(process.argv);

var total = program.number;

var read = function () {
    return Promise.map(_.range(total), function (i) {
        return User.findById(_.random(total)).exec();
    });
}

console.log('Listen on "' + program.event + '", test query num', total);

//mongoose.connection.on(program.event, function () {
    Promise.map(_.range(4), function (i) {
      console.log('Begin read test...#' + (i + 1));
      return read()
      .delay(4000)
      .then(() => {
        return new Promise((resolve) => {
          setTimeout(resolve, 4000)
        })
      })
    }, {concurrency: 1})
    .then(function () {
        console.log('done');
        // process.exit();
    })
    .catch(function (err) {
        console.log(err && err.stack);
        // process.exit(-1);
    })

//});

