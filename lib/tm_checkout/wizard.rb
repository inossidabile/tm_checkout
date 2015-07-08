module TmCheckout
  #
  # DSL evaluator allowing the better format of rules
  #
  # @see Calculator
  #
  class Wizard
    def self.gather(&block)
      wizard = Wizard.new
      wizard.instance_eval(&block)
      wizard
    end

    def initialize
      @rules = {}
    end

    def method_missing(code, *prices)
      @rules[code.upcase] = prices if prices.any?
      RulesHash.convert_key(code)
    end

    def rules
      @rules
    end
  end
end