#!/bin/sh -l

gem install faraday
php "/actions/$1.rb"
