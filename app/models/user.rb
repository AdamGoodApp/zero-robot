class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :api_keys
  has_many :toolpaths

  belongs_to :robot

  validates :email, presence: true

  before_create :set_admin
  before_create :set_robot

  def admin?
    role == "admin"
  end

  def client?
    role == "client"
  end

  def copy_scene(toolpath)
    name = Time.now.strftime("%d%m%y-") + toolpath[:name]
    toolpaths.create(name: name, scene: toolpath[:scene])
  end


  private

  def set_admin
    User.where(role: "admin").empty? ? self.role = "admin" : self.role = "client"
  end

  def set_robot
    self.robot = Robot.active
  end

end
