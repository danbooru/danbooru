module UserUpgradesHelper
  def cents_to_usd(cents)
    number_to_currency(cents / 100, precision: 0)
  end
end
