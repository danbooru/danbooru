module ArtistCommentariesHelper
  def format_commentary_title(title, classes: "")
    tag.h3 do
      tag.span(class: "prose #{classes}") do
        format_text(title, disable_mentions: true, inline: true)
      end
    end
  end

  def format_commentary_description(description, classes: "")
    tag.div(class: "prose #{classes}") do
      format_text(description, disable_mentions: true)
    end
  end
end
