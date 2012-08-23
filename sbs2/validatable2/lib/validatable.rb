# gem 'activesupport', '2.3.5'

require 'validatable/errors'
require 'validatable/macros'
require 'validatable/validatable'
require 'validatable/validations/validation_base'
require 'validatable/validations/validates_format_of'
require 'validatable/validations/validates_presence_of'
require 'validatable/validations/validates_acceptance_of'
require 'validatable/validations/validates_confirmation_of'
require 'validatable/validations/validates_length_of'
require 'validatable/validations/validates_true_for'
require 'validatable/validations/validates_numericality_of'
require 'validatable/validations/validates_exclusion_of'
require 'validatable/validations/validates_inclusion_of'
require 'validatable/validations/validates_each'
require 'validatable/validations/validates_associated'

module Validatable
  Version = '1.8.4'
end