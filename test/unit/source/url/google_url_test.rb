require "test_helper"

module Source::Tests::URL
  class GoogleUrlTest < ActiveSupport::TestCase
    context "Google URLs" do
      should be_image_url(
        "https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=s400",
        "https://lh3.googleusercontent.com/u/0/d/1IzBIuWQTTlxhnx-KghudVQOmoCNvvARt=s0",
        "https://play-lh.googleusercontent.com/n8xsLUPjbQnT4q0DgZtLmx3LMe8kRFh1j0cpANE5QQM75ukQJIpHaa6R7W6mwP6pNBw=s0",
        "http://lh3.ggpht.com/_0qYlQ9JkXnE/Ryz9b1yXRDI/AAAAAAAAAu4/Iv0WPaT7uWY/016.jpg",
        "http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/d/0027.jpg",
        "http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/d/",
      )

      should_not be_image_url(
        "https://photos.app.goo.gl/eHfTwV866X4Vf7Zt5",
        "https://images.app.goo.gl/5uBga7TuPKHxyyR1A",
        "https://forms.gle/CK6UER39rK5qKnnT8",
      )

      should parse_url("https://lh3.googleusercontent.com/C6yBYozE1sXc9o_jsrh29_AYQ6ffCKO-fpooQ5nwuu7FSgQvdGtfSbcJVBUGSDi1VXE9TqYT2g=s0?imgmax=s0").into(
        full_image_url: "https://lh3.googleusercontent.com/C6yBYozE1sXc9o_jsrh29_AYQ6ffCKO-fpooQ5nwuu7FSgQvdGtfSbcJVBUGSDi1VXE9TqYT2g=d",
      )

      should parse_url("http://lh6.ggpht.com/_McwONtqkVLo/S8EZLNU8DfI/AAAAAAAAAKk/NhV7npfiU-U/whitebeard%20death[6].jpg?imgmax=800").into(
        full_image_url: "https://lh6.ggpht.com/_McwONtqkVLo/S8EZLNU8DfI/AAAAAAAAAKk/NhV7npfiU-U/d/whitebeard%20death[6].jpg",
      )

      should parse_url("http://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/").into(
        full_image_url: "https://lh5.ggpht.com/-ykP8cKuqOfU/UKEOptJJvoI/AAAAAAAAMAY/Kp7qo5A50E8/d/",
      )
    end

    should parse_url("https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=s400").into(site_name: "Google")
  end
end
