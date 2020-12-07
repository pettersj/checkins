class Subscriber < ApplicationRecord
  belongs_to :member
  belongs_to :check_in
  belongs_to :account
  has_many :answers

  validates_uniqueness_of :member_id, scope: :check_in_id


  def user
  	self.member.user
  end
end