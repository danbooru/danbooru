class UserEmailChange
  attr_reader :user, :password, :new_email

  def initialize(user, new_email, password)
    @user = user
    @new_email = new_email
    @password = password
  end

  def process
    if User.authenticate(user.name, password)
      user.update(email_address_attributes: { address: new_email })
    else
      user.errors[:base] << "Password was incorrect"
    end
  end
end
