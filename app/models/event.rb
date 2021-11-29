class Event < ApplicationRecord
  extend FriendlyId
  include Ownable

  LANDING_PAGE_PHOTO_HEIGHT = 400

  TIMESTAMP_FORMAT = '%m/%d/%Y %l:%M %P'

  friendly_id :title, use: :slugged

  has_many :attendances, dependent: :destroy

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

  scope :secret, -> { where(secret: true) }
  scope :not_secret, -> { where(secret: false) }
  scope :attended_by, ->(user) { joins(:attendances).where(attendances: {attendee_id: user.id, attendee_type: "User"}) }

  def landing_page_photo
    photo.variant(resize: '1900', combine_options: {gravity: 'North', crop: '1900x500+0+0'})
  end

  def parse_time(timestamp)
    return timestamp if timestamp.is_a?(Time)

    return Time.zone.strptime(timestamp, TIMESTAMP_FORMAT)
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

  def icalendar(event_url)
    cal = Icalendar::Calendar.new
    cal.prodid = "-//#{self.owner.name}//NONSGML ExportToCalendar//EN"
    cal.version = '2.0'
    cal.event do |e|
      e.dtstart = Icalendar::Values::DateTime.new(self.start_time)
      e.dtend = Icalendar::Values::DateTime.new(self.end_time)
      e.summary = self.title
      e.description = self.description
      e.url = event_url
      e.location = self.address.to_s
    end

    return cal
  end

  private

  def ends_after_it_starts
    return unless [end_time, start_time].all?
    unless end_time > start_time
      errors.add(:end_time, t('event.validation.time_is_linear'))
    end
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
