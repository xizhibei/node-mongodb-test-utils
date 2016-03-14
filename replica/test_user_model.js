#!/usr/bin/env node

'use strict';

var _ = require('lodash');
var Promise = require('bluebird');
var mongoose = require('mongoose');

var Schema = mongoose.Schema;

var TestUserSchema = new Schema({
  _id: Number,
  name: String,
  desc: String,
});

var model = mongoose.model('test_user', TestUserSchema);

module.exports = model;