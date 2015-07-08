module TmCheckout
  #
  # Stores prices in the following format:
  # {code: [default_price, discount_quantity => discounted_price]}
  #
  # Special :___ key is reserved to store all products that
  # are part of buy 1 get 1 free program
  #
  class RulesHash < HashWithIndifferentAccess
    def self.convert_key(key)
      key.to_s.upcase.to_sym
    end

    def convert_key(key)
      self.class.convert_key(key)
    end

    def codes
      keys.select{|x| x != :___}
    end

    def has_code?(code)
      code != :___ && include?(code)
    end

    def doubled?(code)
      self[:___] && self[:___].include?(code)
    end
  end
end