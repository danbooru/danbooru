class ChangeSiteCredentialsSiteToBigint < ActiveRecord::Migration[7.1]
  OLD_TO_NEW_SITE_IDS = {
    100 => 1_582_834_045,  # ArtStreet
    200 => 852_466_962,    # Baraag
    300 => 905_104_270,    # Behance
    400 => 920_474_887,    # Blogger
    600 => 95_964_253,     # Ci-En
    800 => 1_911_975_415,  # Deviant Art
    900 => 2_232_280_694,  # Fantia
    1000 => 1_642_487_372, # Furaffinity
    1050 => 1_346_832_700, # Gelbooru
    1075 => 1_704_236_765, # Huashijie
    1100 => 458_145_355,   # Inkbunny
    1200 => 3_521_172_851, # Newgrounds
    1300 => 417_925_447,   # Nico Seiga
    1400 => 3_621_127_813, # Nijie
    1500 => 849_706_620,   # Pawoo
    1600 => 2_803_769_957, # Piapro.jp
    1700 => 11_197_707,    # Pixiv
    1800 => 847_520_205,   # Poipiku
    1900 => 2_910_390_220, # Postype
    2000 => 4_178_719_682, # Plurk
    2050 => 708_778_030,   # Reddit
    2075 => 442_776_123,   # Rule34.xxx
    2100 => 3_174_565_713, # Tinami
    2200 => 526_816_551,   # Tumblr
    2300 => 1_408_455_283, # Twitter
    2400 => 3_859_330_323, # Xfolio
    2450 => 1_935_345_289, # Xiaohongshu
    2500 => 143_330_298,   # Zerochan
  }.freeze

  def up
    change_column :site_credentials, :site, :bigint

    OLD_TO_NEW_SITE_IDS.each do |old_id, new_id|
      execute "UPDATE site_credentials SET site = #{new_id} WHERE site = #{old_id}"
    end
  end

  def down
    OLD_TO_NEW_SITE_IDS.each do |old_id, new_id|
      execute "UPDATE site_credentials SET site = #{old_id} WHERE site = #{new_id}"
    end

    change_column :site_credentials, :site, :integer
  end
end
