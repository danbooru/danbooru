class TagAliasRequest
  def self.command_string(antecedent_name, consequent_name, id = nil)
    if id
      return "[ta:#{id}]"
    end

    "create alias [[#{antecedent_name}]] -> [[#{consequent_name}]]"
  end
end
