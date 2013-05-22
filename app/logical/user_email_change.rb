class UserEmailChange
  attr_reader :user, :password, :new_email

  def initialize(user, new_email, password)
    @user = user
    @new_email = new_email
    @password = password
  end

  def process
    if User.authenticate(user.name, password).nil?
      false
    else
      user.email = new_email
      user.save
    end
  end
end
