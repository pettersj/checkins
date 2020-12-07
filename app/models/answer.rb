class Answer < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :member, optional: true
  belongs_to :account
  belongs_to :check_in
  has_rich_text :body


  # def user
  # 	if self.user_id.nil?
  # 		User.new(name: "Deleted Use")
  # 	else
  # 		User.find(self.user_id)
  # 	end
  # end

  def user_name
  	if self.member_id.nil?
  		self.username
  	else
  		self.user.name
  	end
  end
end
