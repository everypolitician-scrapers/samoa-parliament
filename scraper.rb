#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'
require 'require_all'

require_rel 'lib'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def scrape_list(url)
  warn url
  MemberList.new(response: Scraped::Request.new(url: url).response)
            .member_sections.each do |member_section|
    ScraperWiki.save_sqlite([:name], member_section.to_h)
  end
end

scrape_list('http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/')
