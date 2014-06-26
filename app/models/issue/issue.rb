class Issue::Issue < ActiveRecord::Base
  has_one :content, :class_name => RichContent, :as => :contentable, :dependent => :destroy
  belongs_to :reporter, :class_name => User
  belongs_to :assignee, :class_name => User
  has_many :comments, :class_name => Issue::Comment, :dependent => :destroy
  enum status: [:open, :close]

  validates_presence_of :reporter_id
  validates_presence_of :title
  validates_length_of :title, :minimum => 5, :maximum => 100

  accepts_nested_attributes_for :content

  def build_new_comment
    comment = Issue::Comment.new
    comment.issue = self
    comment.build_content
    comment
  end
end
