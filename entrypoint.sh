#!/bin/sh -l

gem install faraday
ruby "/actions/$1.rb"
