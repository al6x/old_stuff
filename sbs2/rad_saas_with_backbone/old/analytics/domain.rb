Factory.define :domain, class: 'Models::Domain' do |d|
  d.sequence(:name){|i| "domen#{i}.com"}
end

Models::Domain.class_eval do
  create_index [[:name, 1]], unique: true
  create_index [[:views, -1]]
end


class Domain
  inherit Mongo::Model

  db :tmp
  collection :domains

  attr_accessor :name

  attr_writer :views
  def views; @views ||= {} end

  #
  # Validations
  #
  validates_presence_of :name

  def by_months year = Time.now.year
    views = []

    months = self.views[year.to_s] || {}
    11.times do |i|
      views.push (months[(i + 1).to_s] || 0)
    end

    views
  end

  class << self
    def hit! domain_name
      time = Time.now
      update({name: domain_name}, _inc: {"views.#{time.year}.#{time.month}" => 1})
    end
  end
end