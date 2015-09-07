#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

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
  noko.css('div.ngg-gallery-thumbnail a').each do |a|
    data = { 
      id: a.attr('data-image-id'),
      name: a.attr('data-title'),
      image: a.attr('data-src'),
    }
    ScraperWiki.save_sqlite([:id, :name], data)
  end

  unless (next_page = noko.css('div.ngg-navigation a.next/@href')).empty?
    scrape_list(next_page.text) rescue binding.pry
  end
end

scrape_list('http://www.parliament.gov.ws/new/members-of-parliament/member/')
