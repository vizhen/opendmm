module OpenDMM
  module Maker
    module EBody
      include Maker

      module Site
        include HTTParty
        base_uri "av-e-body.com"

        def self.item(name)
          case name
          when /(EBOD)-?(\d{3})/i
            get("/works/#{$1.downcase}/#{$1.downcase}#{$2}.html")
          end
        end
      end

      module Parser
        def self.parse(content)
          page_uri = content.request.last_uri
          html = Nokogiri::HTML(content)
          specs = Utils.hash_from_dl(html.css('div.title-data > dl')).merge(
                  Utils.hash_by_split(html.xpath('//*[@id="content"]/div/div[3]/div[1]/p').text.lines))
          return {
            actresses:     specs['出演女優'].css('a').map(&:text),
            code:          specs['品番'],
            cover_image:   html.css('div.package > a.package-pic').first["href"],
            description:   html.css('div.title-data > p.comment').text,
            genres:        specs['ジャンル'].css('a').map(&:text),
            movie_length:  specs['収録時間'],
            page:          page_uri.to_s,
            release_date:  specs['発売日'].text,
            sample_images: html.css('div.sample-box > ul.sample-pic > li > a').map { |a| a["href"] },
            series:        specs['シリーズ'].text.remove('：'),
            title:         html.css('div.title-data > h1').text,
          }
        end
      end
    end
  end
end
