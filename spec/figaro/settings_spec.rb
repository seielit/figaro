describe Figaro::Settings do
  subject(:set) { Figaro::Settings }

  before do
    ::ENV["HELLO"] = "1234"
    ::ENV["foo"] = "bar"
    ::ENV["foo__bar"] = "baz"

    ::ENV["true1"] = "on"
    ::ENV["true2"] = "true"
    ::ENV["true3"] = "yes"
    ::ENV["true4"] = "enabled"

    ::ENV["false1"] = "off"
    ::ENV["false2"] = "false"
    ::ENV["false3"] = "no"
    ::ENV["false4"] = "disabled"
  end

  describe "#[]" do
    context "building key" do
      it "builds a simple key correctly" do
        expect(set[:foo].key).to eq('foo')
      end

      it "builds a namespaced key correctly" do
        expect(set[:foo][:bar].key).to eq('foo__bar')
      end
    end

    context "accessing values" do
      it "makes ENV values accessible using a simple key" do
        expect(set[:foo].value).to eq('bar')
      end
      it "makes ENV values accessible using a namespaced key" do
        expect(set[:foo][:bar].value).to eq('baz')
      end
    end

    context "type conversion" do
      context "plain methods" do
        it "converts correct values successfully" do
          expect(set[:foo].string).to eq('bar')
          expect(set[:hello].int).to eq(1234)
          expect(set[:hello].float).to eq(1234.0)
          expect(set[:hello].decimal).to eq(BigDecimal(1234))
          expect(set[:true1].bool).to be(true)
          expect(set[:true2].bool).to be(true)
          expect(set[:true3].bool).to be(true)
          expect(set[:true4].bool).to be(true)
          expect(set[:false1].bool).to be(false)
          expect(set[:false2].bool).to be(false)
          expect(set[:false3].bool).to be(false)
          expect(set[:false4].bool).to be(false)
        end

        it "returns nil when value is invalid or non existing" do
          expect(set[:foo].int).to be_nil
          expect(set[:foos].int).to be_nil
        end
      end

      context "bang methods" do
        it "converts correct values successfully" do
          expect(set[:foo].string!).to eq('bar')
          expect(set[:hello].int!).to eq(1234)
          expect(set[:hello].float!).to eq(1234.0)
          expect(set[:hello].decimal!).to eq(BigDecimal(1234))
        end

        it "raises when value is invalid" do
          expect { set[:foo].int! }.to raise_error(Figaro::Settings::DataTypes::InvalidKey)
          expect { set[:foos].int! }.to raise_error(Figaro::Settings::DataTypes::InvalidKey)
        end
      end
    end
  end

  describe "extending" do
    context "requiring" do
      it "requires valid settings without raising error" do
        expect {
          class TestSettings < Figaro::Settings
            requires :hello,
              :int
            requires :foo
          end
        }.not_to raise_error
      end

      it "requires raises an error when requiring non-existing setting" do
        expect {
          class TestSettings < Figaro::Settings
            requires :foos
          end
        }.to raise_error(Figaro::MissingKey)
      end

      it "requires raises an error when requiring invalid setting" do
        expect {
          class TestSettings < Figaro::Settings
            requires :foo,
              :int
          end
        }.to raise_error(Figaro::Settings::DataTypes::InvalidKey)
      end
    end
  end
end
