# The Open Journal

What is this? In short, it's an open review engine for digital media. The goal is to provide a way for a bunch of people to get together (think editorial board) and make comments on a _thing_ (think academic paper). This _thing_ only needs to have a URL (that's open) to be reviewable.

Simple right  ?

You can read more about our motivations for working on this [here](http://theoj.org).

## Getting it running

Install Ruby (Currently at 2.3.0)

Install `node` and `npm`

`npm install -g bower`
`bundle install`
`rake bower:install` or `rake bower:update`

## Does it work?

### Current status

Right now there is only a Ruby logic layer under development. This is the core permission layer we think is important for defining differences between *Authors*, *Editors* and *Reviewers*.

Once this is finished up we'll be adding in a lightweight presentation layer that will make this a more fully-fledged web application.

### Is it green?

Hopefully/probably? You can keep an eye on Travis stuff here:

[![Build Status](https://travis-ci.org/openjournals/theoj.svg?branch=master)](https://travis-ci.org/openjournals/theoj)
