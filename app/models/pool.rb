class Pool < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  belongs_to :creator, :class_name => "User"
  has_many :versions, :class_name => "PoolVersion"
  
  def self.create_anonymous(creator)
    pool = Pool.create(:name => "TEMP - #{Time.now.to_f}.#{rand(1_000_000)}", :creator => creator)
    pool.update_attribute(:name => "anonymous:#{pool.id}")
    pool
  end
  
  def neighbor_posts(post)
    post_ids =~ /\A#{post.id} (\d+)|(\d+) #{post.id} (\d+)|(\d+) #{post.id}\Z/
    
    if $2 && $3
      {:previous => $2.to_i, :next => $3.to_i}
    elsif $1
      {:previous => $1.to_i}
    elsif $4
      {:next => $4.to_i}
    else
      nil
    end
  end
end
