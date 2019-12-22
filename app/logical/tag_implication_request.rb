class TagImplicationRequest
  def self.command_string(antecedent_name, consequent_name, id = nil)
    if id
      return "[ti:#{id}]"
    end

    "create implication [[#{antecedent_name}]] -> [[#{consequent_name}]]"
  end
end
