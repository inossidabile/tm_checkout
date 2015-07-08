require 'spec_helper'

describe TmCheckout do
  it 'has a version number' do
    expect(TmCheckout::VERSION).not_to be nil
  end

  describe TmCheckout::Wizard do
    subject do
      TmCheckout::Wizard.gather do
        # prices
        fr1 3.11
        ap1 5.00, 3 => 4.50
        cf1 11.23

        # buy 1 get 1 free
        ___ fr1, ap1
      end
    end

    describe '.rules' do
      subject { super().rules }

      it do
        is_expected.to eq(
          :FR1 => [3.11],
          :AP1 => [5.0, 3 => 4.5],
          :CF1 => [11.23],
          :___ => [:FR1, :AP1]
        )
      end
    end
  end

  describe TmCheckout::Calculator do
    let(:instance) do
      TmCheckout::Calculator.new do
        # prices
        fr1 3.11
        ap1 5.00, 3 => 4.50
        cf1 11.23

        # buy 1 get 1 free
        ___ fr1
      end
    end

    subject{ instance }

    context 'when incorrect rules passed' do
      subject{ lambda{ TmCheckout::Calculator.new('rules') } }

      it{ is_expected.to raise_error(TmCheckout::IncorrectRules) }
    end

    describe '.scan' do
      context 'when incorrect code passed' do
        subject{ lambda{ TmCheckout::Calculator.new.scan('code') } }

        it do
          is_expected.to raise_error(TmCheckout::WrongCode)
            .with_message('code is not among [:FR1, :AP1, :CF1]')
        end
      end

      context 'when lowercased code passed' do
        subject{ lambda{ TmCheckout::Calculator.new.scan('fr1') } }

        it do
          is_expected.to_not raise_error
        end
      end
    end

    describe '.price_for' do
      subject{ instance.price_for :fr1 }

      context 'when no discounters specified' do
        before{ instance.rules = {fr1: 3.0} }

        context 'when single item is purchased' do
          before{ instance.scan :fr1 }
          it{ is_expected.to eq 3.0 }
        end

        context 'when 5 items is purchased' do
          before{ 5.times { instance.scan :fr1 } }
          it{ is_expected.to eq 3.0 }
        end

        context 'when 50 items is purchased' do
          before{ 50.times{ instance.scan :fr1 } }
          it{ is_expected.to eq 3.0 }
        end
      end

      context 'when discounters specified as single hash' do
        before{ instance.rules = {fr1: [3.0, 10 => 2.0]} }

        context 'when single item is purchased' do
          before{ instance.scan :fr1 }
          it{ is_expected.to eq 3.0 }
        end

        context 'when 5 items is purchased' do
          before{ 5.times { instance.scan :fr1 } }
          it{ is_expected.to eq 3.0 }
        end

        context 'when 50 items is purchased' do
          before{ 50.times{ instance.scan :fr1 } }
          it{ is_expected.to eq 2.0 }
        end
      end

      context 'when discounters specified as multiple hashes' do
        before{ instance.rules = {fr1: [3.0, 4 => 2.0, 30 => 1.0]} }

        context 'when single item is purchased' do
          before{ instance.scan :fr1 }
          it{ is_expected.to eq 3.0 }
        end

        context 'when 5 items is purchased' do
          before{ 5.times { instance.scan :fr1 } }
          it{ is_expected.to eq 2.0 }
        end

        context 'when 50 items is purchased' do
          before{ 50.times{ instance.scan :fr1 } }
          it{ is_expected.to eq 1.0 }
        end
      end
    end

    describe '.codes' do
      before{ 3.times { instance.scan :fr1 } }

      context 'when called directly' do
        subject{ instance.codes }
        it{ is_expected.to eq [:FR1]*3 }
      end

      context 'when called thru alias' do
        subject{ instance.to_a }
        it{ is_expected.to eq [:FR1]*3 }
      end
    end

    describe '.calculate' do
      context 'when called directly' do
        subject{ instance.calculate }

        context 'with sequence 1' do
          before do
            instance.scan :fr1
            instance.scan :ap1
            instance.scan :fr1
            instance.scan :cf1
          end

          it{ is_expected.to eq 22.25 }
        end

        context 'with sequence 2' do
          before do
            instance.scan :fr1
            instance.scan :fr1
          end

          it{ is_expected.to eq 3.11 }
        end

        context 'with sequence 3' do
          before do
            instance.scan :ap1
            instance.scan :ap1
            instance.scan :fr1
            instance.scan :ap1
          end

          it{ is_expected.to eq 16.61 }
        end
      end
    end
  end
end
