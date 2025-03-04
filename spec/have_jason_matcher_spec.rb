require 'spec_helper'

require 'jason_spec'

describe Jason::HaveJasonMatcher do
  it "should match non-rooted objects" do
    expect(%({"first_name":"Jason","last_name":"Voorhees"})).to have_jason(
      [:first_name, :last_name]
    )
  end

  it "should negate match non-rooted objects" do
    expect(%({"first_name":"Jason","last_name":"Voorhees"})).to_not have_jason(
      [:url, :email]
    )
  end

  it "should match rooted objects" do
    expect(%({"user":{"first_name":"Jason","last_name":"Voorhees"}})).to have_jason(
      { user: [:first_name, :last_name] }
    )
  end

  it "should negate match rooted objects" do
    expect(%({"user":{"first_name":"Jason","last_name":"Voorhees"}})).to_not have_jason(
      { user: [:email, :url] }
    )
  end

  describe "With given object" do
    class User
      attr_reader :first_name, :last_name
      def initialize(fn, ln)
        @first_name = fn; @last_name = ln
      end
    end

    let(:user) { User.new("Jason", "Voorhees") }

    it "should exactly match rooted object" do
      expect(%({"user":{"first_name":"Jason","last_name":"Voorhees"}})).to have_jason(
        { user: { user => [:first_name, :last_name] } }
      )
    end

    it "should negate exactly match rooted object" do
      expect(%({"user":{"first_name":"Freddy","last_name":"Kruger"}})).to_not have_jason(
        { user: { user => [:first_name, :last_name] } }
      )
    end

    it "should exactly match non-rooted object" do
      expect(%({"first_name":"Jason","last_name":"Voorhees"})).to have_jason(
        { user => [:first_name, :last_name] }
      )
    end

    it "should negate exactly matched non-rooted object" do
      expect(%({"user":{"first_name":"Freddy","last_name":"Kruger"}})).to_not have_jason(
        { user => [:first_name, :last_name] }
      )
    end
  end

  describe "With Jason::Spec" do
    it "takes a Jason::Spec" do
      expect(%([{"name":"Alexis"},{"name":"Ali"},{"name":"Freddy Kruger"}])).to have_jason(
        Jason.spec(type: :array, each: [ :name ])
      )
    end
  end
end
