require 'nokogiri'
require 'open-uri/cached'
require 'field_serializer'
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
    noko.xpath('//div[@class="entry"]/table[1]/tbody/tr').map do |a|
      name_and_party = a.xpath('td/text()')[1].text
      party_id = name_and_party.split('(')[-1].gsub(')','')
      data = {
        name: name_and_party.split('(')[0].tidy,
        party_id: party_id,
        party_name: party_list[party_id],
        area: a.xpath('td/text()')[2].text.tidy,
        term: 16
      }
    end
  end

  private

  attr_reader :url

  def party_list
    {
      'H' => 'HRPP',
      'TS' => 'Tautua Samoa'
    }
  end

  def noko
    @noko ||= Nokogiri::HTML(open(url).read)
  end
end
