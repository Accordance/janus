#!/bin/bash
bundle --version || gem install bundler
bundle install
bundle exec rake build:committed_version
