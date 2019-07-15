class Event < ApplicationRecord
  include Ownable

  LANDING_PAGE_PHOTO_HEIGHT = 400

  TIMESTAMP_FORMAT = '%m/%d/%Y %l:%M %P'

  has_many :attendances
  has_many :attendees, through: :attendances, class_name: 'User'

  # photo for header of event, will be thumbnailed for index view
  has_one_attached :photo

  # events can be commented on
  acts_as_commontable dependent: :destroy

  has_many :polls, dependent: :destroy
  belongs_to :address

  accepts_nested_attributes_for :address, update_only: true

  validates :start_time, :end_time, presence: true

  validate :ends_after_it_starts

  validates_associated :address

  def landing_page_photo
    photo.variant(resize: '1700', combine_options: {gravity: 'North', crop: '1700x500+0+0'})
  end

  def parse_time(timestamp)
    return timestamp if timestamp.is_a?(Time)

    return Time.strptime(timestamp, TIMESTAMP_FORMAT)
  rescue ArgumentError
    nil
  end

  def start_time=(value)
    super(parse_time(value))
  end

  def start_time_str
    start_time.try(:strftime, TIMESTAMP_FORMAT)
  end

  def end_time=(value)
    super(parse_time(value))
  end

  def end_time_str
    end_time.try(:strftime, TIMESTAMP_FORMAT)
  end

  private

  def ends_after_it_starts
    return unless [end_time, start_time].all?
    unless end_time > start_time
      errors.add(:end_time, "End time must be after start time.")
    end
  end
end
