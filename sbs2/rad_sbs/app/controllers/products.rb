class Products < Items
  def buy
    @order = Models::Order.new
  end

  def checkout
    @order = Models::Order.new params.order

    respond_to do |f|
      if @order.valid?
        flash.sticky_info = t :order_created, name: @model.name, price: @model.price_with_currency
        OrderMailer.submit(@order, @model).deliver
        f.js
      else
        f.js{render action: :buy}
      end
    end
  end
end