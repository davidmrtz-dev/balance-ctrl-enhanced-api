require 'rails_helper'

RSpec.describe Api::IncomesController, type: :controller do
  let!(:user) { UserFactory.create(email: 'user@example.com', password: 'password') }
  let!(:balance) { BalanceFactory.create_with_attachments(user: user) }

  describe 'GET /api/incomes' do
    login_user

    it 'returns paginated incomes' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(parsed_response[:incomes].map { |i| i[:id] }).to match_array(Income.ids)
    end
  end

  describe 'POST /api/incomes' do
    subject(:action) {
      post :create, params: {
        income: {
          transaction_type: 'current',
          amount: 10_000,
          description: 'Salary',
          frequency: :monthly
        }
      }
    }

    login_user

    it 'creates an income' do
      expect { action }.to change { Income.count }.by 1

      action

      expect(response).to have_http_status(:no_content)
    end

    xit 'handles validation error' do
      post :create, params: {
        income: {
          frequency: nil
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end