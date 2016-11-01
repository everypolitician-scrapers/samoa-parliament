require 'nokogiri'
require 'open-uri/cached'
require 'field_serializer'
require_relative 'member'
OpenURI::Cache.cache_path = '.cache'

class Members
  include FieldSerializer

  def initialize(url)
    @url = url
  end

  field :members do
    legislature_members
  end

  def legislature_members
    noko.xpath('//div[@class="entry"]/table[1]/tbody/tr').map do |row|
      Member.new(row).to_h
    end
  end

  private

  attr_reader :url

  def noko
    @noko ||= Nokogiri::HTML(open(url).read)
  end
end
