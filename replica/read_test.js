#!/usr/bin/env node

'use strict'

var mongoose = require('mongoose');
var program = require('commander');
var Promise = require('bluebird');
var _ = require('lodash');

var User = require('./test_user_model');

program
  .version('0.0.1')
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

mongoose.connection.on(program.event, function () {
    console.log('Begin read test...');
    read()
    .then(function () {
        console.log('done');
        process.exit();
    })
    .catch(function (err) {
        console.log(err);
        process.exit(-1);
    })

});

