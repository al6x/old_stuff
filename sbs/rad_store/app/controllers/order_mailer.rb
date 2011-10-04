class OrderMailer
  # TODO3 use Rad::Mailer instead of Rad::Mailer::MailerController
  inherit Rad::Mailer::MailerController
  
  def submit order, product
    request = workspace.request
    store_url = "http://#{request.normalized_domain}"
    product_url = path(product, host: request.normalized_domain)
    
    @to = rad.store.order_processing_email
    @from = rad.users.email
    @subject = t :submit_order_title, product_name: product.name, product_price: product.price_with_currency
    @body = t(
      :submit_order_text, 
      
      store_url: "<a href='#{store_url}'>#{store_url}</a>",
      
      product_name: product.name, 
      product_price: product.price_with_currency,
      product_url: "<a href='#{product_url}'>#{product.name}</a>",

      buyer_name: order.name,
      buyer_phone: order.phone,
      buyer_details: order.details
    )      
  end
end