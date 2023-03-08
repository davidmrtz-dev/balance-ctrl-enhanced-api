class Transaction < ApplicationRecord
  belongs_to :balance
  has_many :payments, as: :paymentable, dependent: :destroy

  enum transaction_type: { current: 0, fixed: 1 }, _default: :current
  enum frequency: { weekly: 0, biweekly: 1, monthly: 2 }

  after_create :generate_payment, if: -> { transaction_type.eql?('current') }

  validates :transaction_date, presence: true
  validates :amount, numericality: { greater_than: 0 }, on: %i[create update]
  validate :transaction_date_not_after_today

  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :from_user, -> (user) { where({ balance: { user: user }}) }

  private

  def transaction_date_not_after_today
    return if transaction_date.nil? || transaction_date < Time.zone.now

    errors.add(:transaction_date, 'can not be after today')
  end

  def generate_payment
    payments.create!(amount: self.amount, status: :applied)
  end
end
