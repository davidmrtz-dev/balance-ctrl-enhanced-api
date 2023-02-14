class Outcome < Transaction
  validates :frequency, absence: true
  validates :purchase_date, presence: true
  validates :quotas, absence: true, if: -> { transaction_type.eql?('current') }
  validates :quotas, presence: true, if: -> { transaction_type.eql?('fixed') }
  validate :purchase_date_not_after_today, on: :create

  default_scope -> { order(purchase_date: :desc) }
  scope :with_balance_and_user, -> { joins(balance: :user) }
  scope :current_types, -> { where(transaction_type: :current) }
  scope :fixed_types, -> { where(transaction_type: :fixed) }
  scope :from_user, lambda { |user|
    where({ balance: { user: user }})
  }

  before_destroy :add_balance_amount, if: -> { transaction_type.eql?('current') }
  after_create :substract_balance_amount, if: -> { transaction_type.eql?('current') }
  after_create :generate_payments, if: -> { transaction_type.eql?('fixed') }



  private

  def purchase_date_not_after_today
    return if purchase_date.nil? || purchase_date < Time.zone.now

    errors.add(:purchase_date, 'can not be after today')
  end

  def add_balance_amount
    balance.current_amount += amount
    balance.save
  end

  def substract_balance_amount
    balance.current_amount -= amount
    balance.save
  end

  def generate_payments
    amount_for_quota = amount / quotas

    quotas.times do
      payments.create!(amount: amount_for_quota)
    end
  end
end
