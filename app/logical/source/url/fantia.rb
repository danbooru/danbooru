# frozen_string_literal: true

# Unhandled:
#
# https://fantia.jp/commissions/64988
# https://fantia.jp/profiles/tus_2n9n0fm05fizg

class Source::URL::Fantia < Source::URL
  attr_reader :full_image_url, :candidate_full_image_urls, :download_url, :fanclub_id, :username, :post_id, :product_id

  def self.match?(url)
    url.domain == "fantia.jp"
  end

  def parse
    case [host, *path_segments]

    # posts:
    # https://c.fantia.jp/uploads/post/file/1070093/main_16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg (sample)
    # https://c.fantia.jp/uploads/post/file/1132267/main_webp_2a265470-e551-409c-b7cb-04437fd6ab2c.webp (sample; full: https://c.fantia.jp/uploads/post/file/1132267/2a265470-e551-409c-b7cb-04437fd6ab2c.jpg)
    # https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg
    # https://cc.fantia.jp/uploads/post_content_photo/file/4563389/main_a9763427-3ccd-4e51-bcde-ff5e1ce0aa56.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS80NTYzMzg5L21haW5fYTk3NjM0MjctM2NjZC00ZTUxLWJjZGUtZmY1ZTFjZTBhYTU2LmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxMzk3OH19fV19&Signature=jyW5ankfO9uCHlKkozYU9RPpO3jzKTW2HuyXgS81i~cRgrXcI9orYU0IXuiit~0TznIyXbB7F~6Z790t7lX948PYAb9luYIREJC2u7pRMP3OBbsANbbFE0o4VR-6O3ZKbYQ4aG~ofVEZfiFVGoKoVtdJxj0bBNQV29eeFylGQATkFmywne1YMtJMqDirRBFMIatqNuunGsiWCQHqLYNHCeS4dZXlOnV8JQq0u1rPkeAQBmDCStFMA5ywjnWTfSZK7RN6RXKCAsMTXTl5X~I6EZASUPoGQy2vHUj5I-veffACg46jpvqTv6mLjQEw8JG~JLIOrZazKZR9O2kIoLNVGQ__
    # from file download: https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnQvZmlsZS8xODMwOTU2L2NiY2RmY2JlXzIwMjIwMjI0XzEyMF8wNDBfMTAwLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxNDU4Nn19fV19&Signature=d1nw8gs9vcshIAeEH4oESm9-7z6y4A7MfoIRRvtUtV9iqTNA8KM0ORuCI7NwEoYc1VHsxy9ByeuSBpNaJoknnc3TOmHFhVRcLn~OWpnWqiHEPpMcSEG7uGlorysjEPmYYRGHjE7LJYcWiiJxjZ~fSBbYzxxwsjroPm-fyGUtNhdJWEMNp52vHe5P9KErb7M8tP01toekGdOqO-pkWm1t9xm2Tp5P7RWcbtQPOixgG4UgOhE0f3LVwHGHYJV~-lB5RjrDbTTO3ezVi7I7ybZjjHotVUK5MbHHmXzC1NqI-VN3vHddTwTbTK9xEnPMR27NHSlho3-O18WcNs1YgKD48w__
    #
    # products:
    # https://c.fantia.jp/uploads/product/image/249638/main_fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg
    # https://c.fantia.jp/uploads/product_image/file/219407/main_bd7419c2-2450-4c53-a28a-90101fa466ab.jpg (sample)
    # https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg
    #
    # blog:
    # https://fantia.jp/posts/2533616/album_image?query=YsSkcpdnlam4JOy5dGHafbrSgfCZoMUmfrWD1XEouNkfO9Qk%2BC5Arv7ovxaiIo%2FEeJe5TI9mWDodDBp%2BzIIh70HJ6c0sWH8wMCc%2FM6IhDIKpxE%2BM1Zc1--Ol9M7yLd5TswwnZ5--wZ7u4P1tCVaAoL5ymFfA5Q%3D%3D
    # https://cc.fantia.jp/uploads/album_image/file/326995/00abd740-74d5-4289-be85-782cb8cdd382.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9hbGJ1bV9pbWFnZS9maWxlLzMyNjk5NS8wMGFiZDc0MC03NGQ1LTQyODktYmU4NS03ODJjYjhjZGQzODIucG5nIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzEzMjM2OTYxfX19XX0_&Signature=XSpRUwWyKOpR53aImaRQeBQx1R4e8hShO6cm-bmqXtJVchiigbTKsV-kCBMox1aeISAcN-O8VhujVlYwtOV1pw6WmE8kIrKeMnWteA17lYd6wAW2BUcVlQb6TBdpPA38V0UTRlmM0cypgw1ipmmDTKtjQ8-Tmo368bZqi4w4M6EukgK~L8Ss42K0JBwfiv0VuLTw49hK9-jGjA1gyQdzZXZwXkuClelV7VVHWxTX06yT8Anv6giOyOM1IP35LxfYG9ZhbTkN78TqAviZhQ9aLEceYG8Ua65f0bGMWCSnjeox5-UpiQ4irAlLDAVkKT~Lz5otNzQd2UnFkRiqbRB32A__
    # https://cc.fantia.jp/uploads/album_image/file/326995/main_00abd740-74d5-4289-be85-782cb8cdd382.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9hbGJ1bV9pbWFnZS9maWxlLzMyNjk5NS9tYWluXzAwYWJkNzQwLTc0ZDUtNDI4OS1iZTg1LTc4MmNiOGNkZDM4Mi5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MTMyMjAzODN9fX1dfQ__&Signature=Wmw~M4FjxgpDFYfQmtSE6bmIybdLbsby-SLCMcEPImK1ObbSeCq7GeOuOlwggxFTHU-O2juo-x8f8BCG~YKW1OGHBmHXpQJStw1f5juwHr7gtnM-GKmC3FIXCbWbmsMSpr~8frXOJX0AMHWKBN3aJAnZ01kXF5g9YrC8o31~hlHqDodh9zGNEGFlYkBisfh73Gn6f~Lvu4N8-tdfhedKnPkhy95sc2HTdbIlvfM7hq191BbeGWUwagKtrKIkTFJDWgaLinoZCMFqZDgQ4l8PmdK9UF6wi60iqSeWh~CEsHWinOprdAQVzrg~QDlSOLm2GiPnJjcwYO6D42DbFFmvxw__
    in _, "uploads", image_type, ("file" | "image"), image_id, /(\w+_)?([\w-]+\.\w+)/
      sample = $1
      file = $2

      #  post_id/product_id == image_id only for the first image in a post/product
      case image_type
      in "post" if sample.present? && file_ext == "webp"
        @post_id = image_id
        @candidate_full_image_urls = %w[jpg jpeg png gif].map do |ext|
          "https://c.fantia.jp/uploads/post/file/#{@post_id}/#{file.delete_suffix(".webp")}.#{ext}"
        end
      in "post"
        @post_id = image_id
        @full_image_url = "https://c.fantia.jp/uploads/post/file/#{@post_id}/#{file}"
      in "product"
        @product_id = image_id
        @full_image_url = "https://c.fantia.jp/uploads/product/image/#{@product_id}/#{file}"
      in "product_image"
        @full_image_url = "https://c.fantia.jp/uploads/product_image/file/#{image_id}/#{file}"
      else
        @full_image_url = original_url
      end

    # https://fantia.jp/posts/1143951/download/1830956
    # https://www.fantia.jp/posts/1143951/download/1830956
    in _, "posts", post_id, "download", image_id
      @post_id = post_id
      @download_url = "https://fantia.jp/posts/#{post_id}/download/#{image_id}"

    # https://fantia.jp/posts/2533616/album_image?query=YsSkcpdnlam4JOy5dGHafbrSgfCZoMUmfrWD1XEouNkfO9Qk%2BC5Arv7ovxaiIo%2FEeJe5TI9mWDodDBp%2BzIIh70HJ6c0sWH8wMCc%2FM6IhDIKpxE%2BM1Zc1--Ol9M7yLd5TswwnZ5--wZ7u4P1tCVaAoL5ymFfA5Q%3D%3D
    # https://www.fantia.jp/posts/2533616/album_image?query=ohnfy48oGygFMkmdllgpHQQK61Mvm%2Bxy6%2FukgHOUMsbje%2BKMFaiKmLbP9hYDmeDNbJyiCbzSdN9cj3ovNY2T6N4LnRpH1%2Bpvk69f28QLG8T2zoVz%2BRNr--dGXRIUR3eSWXfSk1--IXeq0EUIc9%2Fmct%2BvbAbPqQ%3D%3D
    in _, "posts", post_id, "album_image" if params[:query].present?
      @post_id = post_id
      @download_url = "https://fantia.jp/posts/#{post_id}/album_image?query=#{Danbooru::URL.escape(params[:query])}"

    # https://fantia.jp/posts/1148334
    # https://fantia.jp/posts/2245222/post_content_photo/14978435
    in _, "posts", /\d+/ => post_id, *rest
      @post_id = post_id

    # https://fantia.jp/products/249638
    in _, "products", /\d+/ => product_id
      @product_id = product_id

    # https://fantia.jp/fanclubs/64496
    # https://fantia.jp/fanclubs/1654/posts
    # https://job.fantia.jp/fanclubs/5734
    in _, "fanclubs", /\d+/ => fanclub_id, *rest
      @fanclub_id = fanclub_id

    # https://fantia.jp/asanagi
    # https://fantia.jp/koruri
    in _, username
      @username = username

    else
      nil
    end
  end

  def image_url?
    path.starts_with?("/uploads/") || download_url.present?
  end

  def page_url
    if @post_id.present?
      "https://fantia.jp/posts/#{@post_id}"
    elsif @product_id.present?
      "https://fantia.jp/products/#{@product_id}"
    end
  end

  def profile_url
    if fanclub_id.present?
      "https://fantia.jp/fanclubs/#{fanclub_id}"
    elsif username.present?
      "https://fantia.jp/#{username}"
    end
  end

  def work_id
    @post_id || @product_id
  end

  def work_type
    if @post_id.present?
      "post"
    elsif @product_id.present?
      "product"
    end
  end
end
