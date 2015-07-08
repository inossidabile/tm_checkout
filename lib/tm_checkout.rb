require "active_support/core_ext/hash"
require "tm_checkout/version"
require "tm_checkout/rules_hash"
require "tm_checkout/wizard"

module TmCheckout
  class IncorrectRules < Exception; end;
  class WrongCode < Exception; end;

  class Calculator
    attr_accessor :rules

    DEFAULT_RULES = Wizard.gather{
      fr1 3.11
      ap1 5.00, 3 => 4.50
      cf1 11.23
      ___ fr1
    }

    def initialize(rules=nil, &block)
      rules ||= Wizard.gather(&block).rules if block_given?

      if rules && !rules.is_a?(Hash)
        raise IncorrectRules
      end

      self.rules = rules || DEFAULT_RULES.rules
      @codes     = []
    end

    def rules=(value)
      @rules = RulesHash.new(value)
    end

    def ensure!(code)
      raise WrongCode.new("#{code} is not among #{@rules.codes.inspect}") unless @rules.has_code?(code)
      code
    end

    def scan(code)
      @codes << RulesHash.convert_key(ensure! code)
    end

    def codes
      @codes
    end

    def price_for(code)
      code     = @rules.convert_key(ensure! code)
      quantity = @codes.count{|x| x == code}

      return @rules[code] unless @rules[code].is_a?(Array)

      price = @rules[code].first

      @rules[code][1..-1].each do |discounters|
        discounters.each do |required_quantity, new_price|
          return price if quantity < required_quantity
          price = new_price
        end
      end

      price
    end

    def calculate
      cart  = codes.each_with_object(Hash.new(0)){|code, hash| hash[code] += 1}
      price = 0.0

      cart.each do |code, quantity|
        quantity = quantity.divmod(2).inject(:+) if @rules.doubled?(code)
        price   += price_for(code)*quantity
      end

      price
    end

    alias :to_f :calculate
    alias :to_a :codes
  end
end