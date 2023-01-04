# frozen_string_literal: true

class Source::URL::Zerochan < Source::URL
  attr_reader :full_image_url, :title, :size, :work_id, :filetype

  def self.match?(url)
    url.domain == "zerochan.net"
  end

  def parse
    case [domain, *path_segments]

    # https://s4.zerochan.net/600/24/13/90674.jpg
    # http://static.zerochan.net/full/24/13/90674.jpg
    in "zerochan.net", ("full" | /^\d+$/) => size, /\d{2}/ => first_subdir, /\d{2}/ => second_subdir, /(\d+)\.(jpg|png|gif)$/ => filename
      @work_id = $1
      @filetype = $2
      @full_image_url = "https://static.zerochan.net/full/#{first_subdir}/#{second_subdir}/#{filename}"

    # https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png
    # https://s1.zerochan.net/Cocoa.Cookie.600.2957938.jpg
    # http://s4.zerochan.net/Tachibana.Kanade.full.1432739.jpg
    # https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg  <- does not fall under \w
    # https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg  <- same as above
    in "zerochan.net", /^(.*?)\.(full|\d+)\.(\d+)\.(jpg|png|gif)$/ => filename
      @title = $1
      @size = $2
      @work_id = $3
      @filetype = $4

      @full_image_url = "https://static.zerochan.net/#{title}.full.#{work_id}.#{filetype}"

    # http://www.zerochan.net/full/1567893
    in "zerochan.net", "full", /^\d+$/ => work_id
      @work_id = work_id

    # http://www.zerochan.net/1567893
    # http://www.zerochan.net/1567893#full
    in "zerochan.net", /^(\d+)(?:#(?:full)?)?$/
      @work_id = $1

    else
      nil
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    return unless work_id.present?
    "https://www.zerochan.net/#{work_id}#full"
  end
end
