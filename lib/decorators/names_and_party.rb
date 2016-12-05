require 'scraped'

class NamesAndParty < Scraped::Response::Decorator
  def body
    doc = Nokogiri::HTML(super)
    doc.xpath('//div[@class="entry"]/table[1]/tbody/tr/td[2]').each do |member_row|
      name_and_party = member_row.text.split(/\s(?=\()/)
      party = Nokogiri::XML::Node.new 'span', doc
      party.content = name_and_party.last
      party['class'] = 'ep_member_party'
      name = Nokogiri::XML::Node.new 'span', doc
      name.content = name_and_party.first
      name['class'] = 'ep_member_name'
      member_row.content = ''
      member_row.add_child(name)
      member_row.add_child(party)
    end
    doc.to_s
  end
end
