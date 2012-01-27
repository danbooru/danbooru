Factory.define(:artist) do |f|
  f.name {rand(1_000_000).to_s}
  f.is_active true
end
