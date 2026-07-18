class Event < ApplicationRecord
  extend FriendlyId
  include Ownable

  LANDING_PAGE_PHOTO_WIDTH = 1900
  LANDING_PAGE_PHOTO_HEIGHT = 500
  LANDING_PAGE_PHOTO_LIST_HEIGHT = 400

  TIMESTAMP_FORMAT = '%s'

  after_save :remember_landing_page_photo_prewarm
  after_commit :prewarm_landing_page_photo

  friendly_id :title, use: :history

  has_many :attendances, dependent: :destroy

  # photo for header of event, will be thumbnailed for index view
  has_one_attached :photo

  has_many :comments, dependent: :destroy
  has_many :polls, dependent: :destroy
  belongs_to :address

  accepts_nested_attributes_for :polls, allow_destroy: true
  accepts_nested_attributes_for :address

  validates :start_time, :end_time, presence: true

  validate :ends_after_it_starts

  validates_associated :address

  scope :attended_by, ->(user) { joins(:attendances).where(attendances: {attendee_id: user.id, attendee_type: "User"}) }

  def landing_page_photo_transformations
    {
      resize: LANDING_PAGE_PHOTO_WIDTH.to_s,
      crop: "#{LANDING_PAGE_PHOTO_WIDTH}x#{LANDING_PAGE_PHOTO_HEIGHT}+0+#{header_photo_crop_y_offset}"
    }
  end

  def landing_page_photo
    photo.variant(landing_page_photo_transformations)
  end

  def landing_page_photo_ready?
    return false unless photo.attached?

    photo.blob.variant_records.exists?(
      variation_digest: landing_page_photo.variation.digest
    )
  end

  def header_photo_crop_y_offset
    # unanalyzed photos may have nil metadata - treat it as a missing width
    width = (photo.metadata || {})["width"]
    width_scale = width ? LANDING_PAGE_PHOTO_WIDTH.to_f / width : 1
    photo_crop_y_offset * width_scale
  end

  def allows_plus_ones?
    plus_one_max != 0
  end

  def has_plus_one_limit?
    allows_plus_ones? && plus_one_max > 0
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

  def remember_landing_page_photo_prewarm
    @prewarm_landing_page_photo = photo.attached? && (
      saved_change_to_photo_crop_y_offset? || attachment_changes["photo"].present?
    )
  end

  def prewarm_landing_page_photo
    return unless @prewarm_landing_page_photo

    photo.blob.preprocessed(landing_page_photo_transformations)
  ensure
    @prewarm_landing_page_photo = false
  end

  def ends_after_it_starts
    return unless [end_time, start_time].all?
    unless end_time > start_time
      errors.add(:end_time, :ends_before_start)
    end
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
