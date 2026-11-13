require "application_system_test_case"

class MobileGesturesMobileChromeTest < MobileChromeSystemTestCase
  # Swipe across the screen with real touch events. `dx` < 0 swipes left, `dx` > 0 swipes right.
  #
  # @param from [Array<Integer>] the [x, y] point where the swipe starts.
  # @param fingers [Integer] how many fingers to swipe with. Extra fingers are placed 40px below the first one.
  # @param steps [Integer] how many touch moves to send. Each one takes the browser about 30ms to process.
  def swipe(dx: 0, dy: 0, duration: 0.1, from: [200, 400], fingers: 1, steps: 5)
    page.driver.with_playwright_page do |playwright_page|
      cdp = playwright_page.context.new_cdp_session(playwright_page)
      touch_points = lambda do |progress|
        (0...fingers).map do |finger|
          { id: finger, x: from[0] + (dx * progress), y: from[1] + (finger * 40) + (dy * progress) }
        end
      end

      cdp.send_message("Input.dispatchTouchEvent", params: { type: "touchStart", touchPoints: touch_points.call(0) })
      (1..steps).each do |step|
        sleep duration / steps
        cdp.send_message("Input.dispatchTouchEvent", params: { type: "touchMove", touchPoints: touch_points.call(step.to_f / steps) })
      end
      cdp.send_message("Input.dispatchTouchEvent", params: { type: "touchEnd", touchPoints: [] })
    end
  end

  # @return [Array<Integer>] the [x, y] point in the middle of the element matching the CSS selector.
  def center_of(selector)
    page.evaluate_script(<<~JS)
      (() => {
        const rect = document.querySelector(#{selector.to_json}).getBoundingClientRect();
        return [Math.round(rect.x + rect.width / 2), Math.round(rect.y + rect.height / 2)];
      })()
    JS
  end

  def assert_not_navigated_after_swipe(**)
    assert_no_navigation do
      swipe(**)
      sleep 0.5
    end
  end

  context "On the post index page" do
    setup do
      @posts = create_list(:post, 3)
      visit posts_path(page: 2, limit: 1)
    end

    should "go to the next page when swiping left" do
      swipe(dx: -200)
      assert_current_path(/page=3/)
    end

    should "go to the previous page when swiping right" do
      swipe(dx: 200)
      assert_current_path(/page=1/)
    end

    should "not navigate when scrolling vertically" do
      assert_not_navigated_after_swipe(dx: -80, dy: -300)
    end

    should "not navigate on a slow drag" do
      assert_not_navigated_after_swipe(dx: -100, duration: 1.0)
    end

    should "not navigate on a quick flick that's too short" do
      assert_not_navigated_after_swipe(dx: -55, duration: 0, steps: 1)
    end

    should "not navigate when swiping with two fingers" do
      assert_not_navigated_after_swipe(dx: -200, fingers: 2)
    end

    should "not navigate when swiping right on the first page" do
      visit posts_path(page: 1, limit: 1)
      assert_not_navigated_after_swipe(dx: 200)
    end

    should "not navigate when the swipe starts in the search box" do
      assert_not_navigated_after_swipe(dx: -200, from: center_of("#search-box input[name=tags]"))
    end

    should "not navigate when text is selected" do
      page.execute_script("window.getSelection().selectAllChildren(document.body)")
      assert_not_navigated_after_swipe(dx: -200)
    end

    should "not navigate on screens wider than a phone" do
      page.driver.with_playwright_page { |playwright_page| playwright_page.viewport_size = { width: 1024, height: 915 } }
      visit posts_path(page: 2, limit: 1)

      assert_not_navigated_after_swipe(dx: -200)
    end

    should "not navigate when the page is pinch-zoomed" do
      page.driver.with_playwright_page do |playwright_page|
        playwright_page.context.new_cdp_session(playwright_page).send_message("Emulation.setPageScaleFactor", params: { pageScaleFactor: 2 })
      end
      assert_equal 2, page.evaluate_script("window.visualViewport.scale")

      assert_not_navigated_after_swipe(dx: -200)
    end

    should "allow pinch zooming and text selection" do
      assert_equal "auto", page.evaluate_script("getComputedStyle(document.body).touchAction")
      assert_equal "auto", page.evaluate_script("getComputedStyle(document.body).userSelect")
    end

    should "not navigate when the user has disabled mobile gestures" do
      fast_signin(create(:user, disable_mobile_gestures: true))
      visit posts_path(page: 2, limit: 1)

      assert_not_navigated_after_swipe(dx: -200)
    end
  end

  context "On the post show page" do
    setup do
      # The post we open needs a real image. Plain test posts have no image file, and a broken image isn't shrunk to
      # fit the screen, so the page would scroll sideways and the browser would treat the swipe as a scroll.
      @posts = [
        create(:post, tag_string: "touhou"),
        create(:post_with_file, tag_string: "touhou"),
        create(:post, tag_string: "touhou"),
      ]
    end

    should "go to the next post in the search when swiping left" do
      visit post_path(@posts[1], q: "touhou")
      swipe(dx: -200)
      assert_current_path(post_path(@posts[0], q: "touhou"))
    end

    should "go to the previous post in the search when swiping right" do
      visit post_path(@posts[1], q: "touhou")
      swipe(dx: 200)
      assert_current_path(post_path(@posts[2], q: "touhou"))
    end

    should "go to the next post in the pool when swiping left" do
      pool = as(create(:user)) { create(:pool, post_ids: @posts.map(&:id)) }
      visit post_path(@posts[1], q: "pool:#{pool.id}")
      swipe(dx: -200)
      assert_current_path(post_path(@posts[2], q: "pool:#{pool.id}"))
    end
  end
end
