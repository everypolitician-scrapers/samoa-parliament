#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'colorize'
require_relative 'lib/members'
require 'pry'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

URL = 'http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/'.freeze

Members.new(URL).to_h[:members].each do |member|
  ScraperWiki.save_sqlite([:name], member)
end
