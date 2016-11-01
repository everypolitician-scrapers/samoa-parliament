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
# We need to tweak the document slightly as the trible names of one member are
# not capitalized in the same way as the trible names of other members. We're doing this now
# to avoid complications later
BODY = open(URL).read.gsub('Fatialofa Lupesoliai Tuilaepa', 'FATIALOFA LUPESOLIAI TUILAEPA')
NOKO = Nokogiri::HTML(BODY)

Members.new(NOKO).to_h[:members].each do |member|
  ScraperWiki.save_sqlite([:name], member)
end
