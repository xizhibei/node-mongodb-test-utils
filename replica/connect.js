'use strict';

var _ = require('lodash');
var Promise = require('bluebird');
var mongoose = require('mongoose');
var qs = require('querystring');
mongoose.Promise = Promise;

var ip = '192.168.99.100';
var initPort = 27018;
var secondaryNum = 4;

var hosts = _.times(secondaryNum + 1, function(i) {
  return ip + ':' + (initPort + i);
});

var url = [
  'mongodb://',
  hosts.join(','),
  '/test?',
  qs.toString({
    'replicaSet': 'test-rs0',
    'readPreference': 'secondaryPreferred'
  })
].join('');

var options = {
  replset: {
    socketOptions: {
      connectTimeoutMS: 1000 * 5,
      keepAlive: 1
    }
  },
  server: {
    poolSize: 10,
    slaveOk: true,
    auto_reconnect: true
  }
};

mongoose.connect(url, options);
mongoose.connection.on('error', function(err) {
  console.log(err);
  process.exit(-1);
});