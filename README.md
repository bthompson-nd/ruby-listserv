# Listserv
A Ruby library for parsing Listserv's .list files.

------------

## Purpose

Suppose you have a large number of L-Soft Listserv mailing lists, and need to programmatically read their settings, member lists, and member roles. With this library all you need to do is pass a Listserv .list filename to the Listserv.new() constructor, and you can then access these facets of your mailing list as if it were a typical Ruby object.

## Installation

You can install this library like any other gem:

### From RubyGems

    gem install listserv

### From Bundler

Add this line to your Gemfile

    gem 'listserv'

Then run this command

    bundle install
    

## Example Usage

    require 'listserv'
    
    my_list = Listserv.new('my-list.list')
    
    # Print all properties, with the exception of the member list
    puts my_list.properties
    
    # Print an array of listserv members
    puts my_list.members
