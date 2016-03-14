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
  .parse(process.argv);

var total = program.number;

var read = function () {
    return Promise.map(_.range(total), function (i) {
        return User.findById(_.random(total)).exec();
    });
}

//mongoose.connection.on('open', function () {
//mongoose.connection.on('fullsetup', function () {
mongoose.connection.on('all', function () {
    console.log('Begin read test...');
    read()
    .then(function () {
        console.log('done');
        process.exit();
    })
    .catch(function (err) {
        console.log(err);
        process.exit();
    })

});

