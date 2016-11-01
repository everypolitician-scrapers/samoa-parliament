require 'nokogiri'
require 'field_serializer'

class Member
  include FieldSerializer

  def initialize(noko)
    @noko = noko
  end

  field :name do
    full_name
  end

  field :honorific_prefix do
    matai_titles.join(';')
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

  def full_name
    name_and_party.split('(').first.tidy
  end

  def matai_titles
    full_name.delete('.')
             .split(' ')
             .select do |w|
      w == w.upcase && w.length > 1
    end.map(&:capitalize)
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
