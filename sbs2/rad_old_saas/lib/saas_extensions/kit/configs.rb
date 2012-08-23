rad.config.class.class_eval do
  [
    :permissions,            :space, false,
    :default_viewers,        :space, false,
    :custom_roles,           :space, false,
    :title,                  :space, false,
    :menu,                   :space, false,
    :additional_menu,        :space, false,
    :logo_url,               :space, false,
    :bottom_text,            :space, false,

    :web_analytics_token,       :account, false,

    # files_size: :account,
    # max_file_size: :account,
    # max_account_files_size: :account
  ].each_slice 3 do |k, target, required|
    define_method(k){method_missing k} unless method_defined? k
    old_k = :"#{k}_without_saas"
    alias_method old_k, k

    define_method k do
      (rad.include?(target) ? rad[target].send(k) : send(old_k)) || (required && raise("key :#{k} not defined!"))
    end

    define_method "#{k}=" do |v|
      raise "invalid usage (:#{k} can be set in SaaS only)!"
    end
  end
end

{
  environment: [
    :language, :space, false
  ],
  face: [
    :theme, :space, false
  ],
  store: [
    :currency,               :space, false,
    :order_processing_email, :space, true
  ],
  router: [
    :default_url, :space, true
  ]
}.each do |component, meta|
  rad.after component, bang: false do
    rad[component].class.class_eval do
      meta.each_slice 3 do |k, target, required|
        define_method k do
          (rad.include?(target) ? rad[target].send(k) : instance_variable_get(:"@#{k}")) || (required && raise("key :#{k} not defined!"))
        end

        define_method "#{k}=" do |v|
          raise "invalid usage (:#{k} can be set in SaaS only)!"
        end
      end
    end
  end
end