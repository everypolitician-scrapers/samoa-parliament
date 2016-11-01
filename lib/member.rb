require 'nokogiri'
require 'field_serializer'

class Member
  include FieldSerializer

  def initialize(noko)
    @noko = noko
  end

  field :name do
    name_and_party.split('(')[0].tidy
  end

  field :party_id do
    party_id
  end

  field :party_name do
    party_list[party_id]
  end

  field :area do
    noko.xpath('td/text()')[2].text.tidy
  end

  field :term do
    16
  end

  private

  attr_reader :noko

  def name_and_party
    noko.xpath('td/text()')[1].text
  end

  def party_id
    name_and_party.split('(')[-1].delete(')')
  end

  def party_list
  {
    'H' => 'HRPP',
    'TS' => 'Tautua Samoa'
  }
  end
end
