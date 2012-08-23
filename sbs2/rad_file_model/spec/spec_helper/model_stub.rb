class ModelStub
  def errors
    @errors ||= {}
  end

  def save
    self.class.before_validate.each{|block| instance_eval &block}

    if errors.empty?
      # save
      self.class.after_save.each{|block| instance_eval &block}
      true
    else
      false
    end
  end

  def delete
    self.class.before_validate.each{|block| instance_eval &block}

    if errors.empty?
      # save
      self.class.after_delete.each{|block| instance_eval &block}
      true
    else
      false
    end
  end

  class << self
    def before_validate
      @before_validate ||= []
    end

    def after_save
      @after_save ||= []
    end

    def after_delete
      @after_delete ||= []
    end
  end
end