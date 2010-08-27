module Jobs
  class CreateTagAlias < Struct.new(:antecedent_name, :consequent_name, :creator_id, :creator_ip_addr)
    def execute
      TagAlias.create(
        :antecedent_name => antecedent_name,
        :consequent_name => consequent_name,
        :creator_id => creator_id,
        :creator_ip_addr => creator_ip_addr
      )
    end
  end
end
