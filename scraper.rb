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
  noko.xpath('//div[@class="entry"]/table[1]/tbody/tr').each do |a|
    name_and_party = a.xpath('td/text()')[1].text
    party_id = name_and_party.split('(')[-1].gsub(')','')
    data = {
      name: name_and_party.split('(')[0].tidy,
      party_id: party_id,
      party_name: party_list[party_id],
      area: a.xpath('td/text()')[2].text.tidy
    }
    ScraperWiki.save_sqlite([:name], data)
  end
end

def party_list
  {
    'H' => 'HRPP',
    'TS' => 'Tautua Samoa'
  }
end

scrape_list('http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/')
