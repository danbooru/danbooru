module Jobs
  class CreateTagImplication < Struct.new(:antecedent_name, :consequent_name, :creator_id, :creator_ip_addr)
    def perform
      TagImplication.create(
        :antecedent_name => antecedent_name,
        :consequent_name => consequent_name,
        :creator_id => creator_id,
        :creator_ip_addr => creator_ip_addr
      )
    end
  end
end
