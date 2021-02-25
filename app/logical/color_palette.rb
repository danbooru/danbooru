module ColorPalette
  module_function

  HUES = {
    grey: 265,
    red: 12,
    orange: 37,
    yellow: 68,
    green: 130,
    azure: 242,
    blue: 257,
    purple: 282,
    magenta: 307,
  }

  SATURATIONS = {
    grey:   [17.5]*10,
    red:    [100, 80, 100, 100, 100, 90, 100, 90, 75, 50],
    yellow: [80, 60, 60, 100, 100, 100, 100, 100, 100, 90],
    green:  [60, 40, 50, 90, 100, 100, 100, 100, 100, 100],
    purple: [100, 70, 90, 100, 100, 100, 100, 100, 80, 80],
    magenta: [100, 70, 90, 100, 100, 100, 100, 100, 80, 80],
  }

  LIGHTNESSES = [
    97.0, # 0
    92.0, # 1
    84.0, # 2
    70.5, # 3
    61.0, # 4
    51.2, # 5
    40.0, # 6
    28.0, # 7
    19.0, # 8
    12.0, # 9
  ]

  def css_rules
    HUES.flat_map do |name, hue|
      LIGHTNESSES.each_with_index.map do |lightness, i|
        saturation = SATURATIONS.dig(name, i) || 100
        hex = Hsluv.hsluv_to_hex(hue, saturation, lightness)

        "--#{name}-#{i}: #{hex}; /* hsluv(#{hue}, #{saturation}, #{lightness}) */"
      end
    end.join("\n")
  end
end
