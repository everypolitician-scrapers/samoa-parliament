#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
require 'require_all'

require_rel 'lib'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  warn url
  noko = noko_for(url)
  noko.xpath('//div[@class="entry"]/table[1]/tbody/tr').each do |a|
    ScraperWiki.save_sqlite(
      [:name],
      MemberSection.new(response: Scraped::Request.new(url: url).response, noko: a).to_h
    )
  end
end

scrape_list('http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/')
