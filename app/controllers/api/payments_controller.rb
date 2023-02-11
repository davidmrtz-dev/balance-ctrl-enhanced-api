module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current = current_user.balance.outcomes
      current_page = paginate(
        current,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        payments: current_page,
        total_pages: total_pages(current.count)
      }
    end

    def fixed
      fixed = current_user.balance.outcomes
      fixed_page = paginate(
        fixed,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        payments: fixed_page,
        total_pages: total_pages(fixed.count)
      }
    end

    private

    def total_pages(count)
      total_pages = count / 5
      count % 5 > 0 ? total_pages + 1 : total_pages
    end
  end
end
