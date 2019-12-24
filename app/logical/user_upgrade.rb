class UserUpgrade
  def self.gold_price
    if Danbooru.config.is_promotion?
      1500
    else
      2000
    end
  end

  def self.platinum_price
    if Danbooru.config.is_promotion?
      3000
    else
      4000
    end
  end

  def self.upgrade_price
    if Danbooru.config.is_promotion?
      1500
    else
      2000
    end
  end
end
