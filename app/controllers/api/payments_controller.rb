module Api
  class PaymentsController < ApiController
    include Pagination

    before_action :authenticate_user!

    def current
      current = current_user.balance.payments_current
      current_page = paginate(
        current,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        current: current_page,
        current_total_pages: total_pages(current.count)
      }
    end

    def fixed
      fixed = current_user.balance.payments_fixed
      fixed_page = paginate(
        fixed,
        limit: params[:limit],
        offset: params[:offset]
      )

      render json: {
        fixed: fixed_page,
        fixed_total_pages: total_pages(fixed.count)
      }
    end

    private

    def total_pages(count)
      total_pages = count / 5
      count % 5 > 0 ? total_pages + 1 : total_pages
    end
  end
end
