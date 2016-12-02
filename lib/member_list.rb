require 'scraped'

class MemberList < Scraped::HTML
  field :member_sections do
    noko.xpath('//div[@class="entry"]/table[1]/tbody/tr').map do |section|
      MemberSection.new(response: response, noko: section)
    end
  end
end
