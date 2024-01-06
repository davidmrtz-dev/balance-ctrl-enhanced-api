return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

%i[debit credit cash].each do |type|
  Billing.create!(
    user: user,
    name: Faker::Finance.stock_market,
    billing_type: type,
    state_date: Time.zone.now
  )
end

10.times do
  name = Faker::Commerce.department(max: 1, fixed_amount: true)

  next if Category.find_by(name: name)

  Category.create!(name: name)
end

balance = Balance.create!(
  user: user,
  title: 'My Balance',
  description: 'My balance description'
)

Income.create!(
  balance: balance,
  description: Faker::Commerce.product_name,
  amount: 50_000.00,
  transaction_date: Time.zone.now
)

6.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Commerce.product_name,
    transaction_date: Time.zone.now,
    amount: 1_500.00
  )
end

Outcome.create!(
  balance: balance,
  transaction_type: 'fixed',
  quotas: 2,
  description: Faker::Commerce.product_name,
  transaction_date: Time.zone.now,
  amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
)

cash = Billing.cash.first
debit = Billing.debit.first
credit = Billing.credit.first

Outcome.all.each do |t|
  cat = Category.all.sample

  t.categories << cat

  billing = if t.transaction_type.eql?('current')
    [cash, debit].sample
  else
    credit
  end

  BillingTransaction.create!(
    billing: billing,
    related_transaction: t
  )

  next if t.transaction_type.eql?('current')
  # Relate payments with balance for fixed outcomes
  t.payments.each do |p|
    BalancePayment.create!(
      balance: balance,
      payment: p
    )
  end
end

Outcome.fixed.first.payments.last.pending!
