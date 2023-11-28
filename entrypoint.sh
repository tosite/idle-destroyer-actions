#!/bin/sh -l

gem install faraday json time
php "/actions/$1.rb"
