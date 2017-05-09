#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  field :members do
    noko.at_css('.entry table').css('tr').map do |tr|
      fragment(tr => MemberRow).to_h
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    td[0].text.tidy
  end

  field :name do
    name_field_parts['name']
  end

  field :area do
    td[2].text.tidy
  end

  field :party_id do
    name_field_parts['partyid']
  end

  field :party do
    party_id
  end

  private

  def td
    noko.css('td')
  end

  # Tofa AUMUA Isaia Lameko (H)
  #  bracketed part = party ID
  def name_field_parts
    td[1].text.tidy.match(/(?<name>.*) \((?<partyid>.*?)\)/)
  end
end

def scraper(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/'
data = scraper(start => MembersPage).members
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id name], data)
