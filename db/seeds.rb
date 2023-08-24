return unless Rails.env.development? || Rails.env.staging?

user = User.create!(
  email: 'user@example.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'David'
)

balance = Balance.create!(
  user: user,
  title: 'My Balance',
  description: 'My balance description'
)

5.times do
  name = Faker::Commerce.department(max: 1, fixed_amount: true)

  cat = Category.find_by(name: name)

  unless cat
    cat = Category.create!(name: name)
  end
end

10.times do
  Income.create!(
    balance: balance,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    amount: Faker::Number.decimal(l_digits: 4, r_digits: 2),
    transaction_date: Time.zone.now
  )
end

5.times do
  Outcome.create!(
    balance: balance,
    description: Faker::Commerce.department(max: 1, fixed_amount: true),
    transaction_date: [
      Time.zone.now - 2.days, Time.zone.now - 1.day, Time.zone.now
    ].sample,
    amount: Faker::Number.decimal(l_digits: 3, r_digits: 2)
  )
end

Outcome.create!(
  balance: balance,
  transaction_type: 'fixed',
  quotas: 6,
  description: Faker::Commerce.department(max: 2, fixed_amount: true),
  transaction_date: 1.day.ago,
  amount: Faker::Number.decimal(l_digits: 4, r_digits: 2)
)

Outcome.all.each do |t|
  cat = Category.all.sample

  t.categories << cat
end
