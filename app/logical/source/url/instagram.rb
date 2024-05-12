# frozen_string_literal: true

# Unhandled:
#
# https://scontent-lga3-1.cdninstagram.com/v/t51.2885-15/sh0.08/e35/s640x640/202831473_394388808595845_6890631933098833028_n.jpg?_nc_ht=scontent-lga3-1.cdninstagram.com&_nc_cat=109&_nc_ohc=Fcle68OyC80AX8VTGxs&edm=AABBvjUBAAAA&ccb=7-4&oh=00_AT_DYX0zhyNR9vo6ZFKfXjzEWqwFLLfEd3qcpAds5KIvnA&oe=6216DDB5&_nc_sid=83d603
# https://instagram.fgyn2-1.fna.fbcdn.net/v/t51.2885-15/260126945_125485689990401_3753783352853967169_n.webp?stp=dst-jpg_e35_s750x750_sh0.08&_nc_ht=instagram.fgyn2-1.fna.fbcdn.net&_nc_cat=105&_nc_ohc=7njl7WM7D1cAX_oe4xv&tn=ZvUMUWKqovKgvpX-&edm=AABBvjUBAAAA&ccb=7-4&ig_cache_key=Mjc2NTM3ODUzMDE2MTA4OTMyNw==.2-ccb7-4&oh=00_AT9T3WAiFaHEf1labFFZiXHjy-8nacOA13AWl6hDEPz_EQ&oe=6230B686&_nc_sid=83d603

class Source::URL::Instagram < Source::URL
  attr_reader :username, :work_id

  def self.match?(url)
    url.domain.in?(%w[instagram.com instagr.am cdninstagram.com]) || (url.domain == "fbcdn.net" && url.subdomain.include?("instagram"))
  end

  def parse
    case [domain, *path_segments]

    # https://www.instagram.com/p/CbDW9mVuEnn/
    # https://www.instagram.com/reel/CV7mHEwgbeF/?utm_medium=copy_link
    # https://www.instagram.com/tv/CMjUD1epVWW/
    in "instagram.com", ("p" | "reel" | "tv"), work_id
      @work_id = work_id

    # https://www.instagram.com/peachmomoko60/p/CyyRYaBxp25/
    in "instagram.com", username, ("p" | "reel" | "tv"), work_id
      @work_id = work_id
      @username = username

    # https://www.instagram.com/itomugi/
    # https://www.instagram.com/itomugi/tagged/
    in "instagram.com", username, *rest
      @username = username.delete_prefix("@")

    # https://www.instagram.com/stories/itomugi/
    in "instagram.com", "stories", username, *rest
      @username = username

    # https://instagr.am/p/CJVuiRZjrB9/
    in "instagr.am", "p", work_id
      @work_id = work_id

    # https://instagr.am/Zurasuta
    in "instagr.am", username
      @username = username

    else
      nil
    end
  end

  def image_url?
    domain.in?(%w[cdninstagram.com fbcdn.net])
  end

  def page_url
    "https://www.instagram.com/p/#{work_id}/" if work_id.present?
  end

  def profile_url
    # Instagram URLs canonically end with "/"
    "https://www.instagram.com/#{username}/" if username.present?
  end
end
