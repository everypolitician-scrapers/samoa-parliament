require 'scraped'

class MemberSection < Scraped::HTML
  field :name do
    noko.at_css('.ep_member_name').text
  end

  field :party_id do
    noko.at_css('.ep_member_party').text.gsub(Regexp.union('(',')'),'')
  end

  field :party_name do
    party_list[party_id]
  end

  field :area do
    noko.xpath('td/text()').last.text
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
