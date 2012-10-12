module SymbolOperatorMethods
  OPERATORS = {
    :eql     => '==',
    :not_eql => '!=',
    :gt      => '>',
    :gte     => '>=',
    :lt      => '<',
    :lte     => '<=',
    :matches => '==',
    
    :does_not_match   => '!=',
    :contains         => '=~',
    :does_not_contain => '!~',
    :substring        => '=@',
    :not_substring    => '!@',
    
    :desc       => '-',
    :descending => '-'
  }
  SLUGS = OPERATORS.keys.freeze

  def to_google_analytics
    t = Garb.to_google_analytics @field || @target
    o = OPERATORS[@operator]

    [:desc, :descending].include?(@operator.to_sym) ? "#{o}#{t}" : "#{t}#{o}"
  end
end

class SymbolOperator
  include SymbolOperatorMethods
  
  def initialize(field, operator)
    @field, @operator = field, operator
  end unless method_defined? :initialize
end

symbol_slugs = if Object.const_defined?('DataMapper')
  # make sure the class is defined
  require 'dm-core/core_ext/symbol'

  # add to_google_analytics to DM's Opeartor
  class DataMapper::Query::Operator
    include SymbolOperatorMethods
  end

  SymbolOperatorMethods::SLUGS - DataMapper::Query::Conditions::Comparison.slugs
else
  SymbolOperatorMethods::SLUGS
end

# define the remaining symbol operators
symbol_slugs.each do |operator|
  Symbol.class_eval <<-RUBY
    def #{operator}
      SymbolOperator.new self, :#{operator}
    end unless method_defined? :#{operator}
  RUBY
end
