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
    member_table.css('tr').map do |tr|
      fragment(tr => MemberRow).to_h
    end
  end

  field :parties do
    # TS has vanished from the page!
    listed_parties + [{ id: "TS", name: "Tautua Samoa" }]
  end

  def member_table
    noko.at_css('.entry table')
  end

  def party_table
    noko.css('.entry table').last
  end

  def listed_parties
    party_table.css('tr').map { |tr| fragment(tr => PartyRow).to_h }
  end
end

class TableRow < Scraped::HTML
  def td
    noko.css('td')
  end
end

class MemberRow < TableRow
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

  private

  # Tofa AUMUA Isaia Lameko (H)
  #  bracketed part = party ID
  def name_field_parts
    td[1].text.tidy.match(/(?<name>.*) \((?<partyid>.*?)\)/)
  end
end

class PartyRow < TableRow
  field :id do
    td[0].text.tidy
  end

  field :name do
    td[1].text.tidy
  end
end

def scraper(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.palemene.ws/new/members-of-parliament/members-of-the-xvi-parliament/'
scraped = scraper(start => MembersPage)
parties = scraped.parties.map { |p| [p[:id], p[:name]] }.to_h

data = scraped.members.map do |mem|
  mem.merge(party: parties[mem[:party_id]], term: 16)
end
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id name], data)
