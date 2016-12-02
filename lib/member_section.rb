require 'scraped'

class MemberSection < Scraped::HTML
  field :name do
    name_and_party.split('(')[0].tidy
  end

  field :party_id do
    name_and_party.split('(')[-1].gsub(')','')
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

  def party_list
    {
      'H' => 'HRPP',
      'TS' => 'Tautua Samoa'
    }
  end

  def name_and_party
    noko.xpath('td/text()')[1].text
  end
end
