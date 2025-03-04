require 'spec_helper'

describe Jason::Spec do
  it "provides a spec class method" do
    expect(Jason).to respond_to(:spec)
    expect(Jason.spec({})).to be_kind_of(Jason::Spec)
  end

  it "refuses unknown specs" do
    spec = Jason.spec(unknown: 1)
    expect(spec).to_not be_fits(:anything)
  end

  describe "Type" do
    it "takes a type spec" do
      spec = Jason::Spec.new(type: Array)
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: type")
    end

    it "Matches by string/symbol" do
      [ "array", "Array", :array, :Array ].each do |type|
        spec = Jason::Spec.new(type: type)
        expect(spec).to be_fits([])
      end

      [ "hash", "Hash", :hash, :Hash ].each do |type|
        spec = Jason::Spec.new(type: type)
        expect(spec).to be_fits({})
      end

      [ "boolean", "Boolean", :boolean, :Boolean ].each_with_index do |type,i|
        spec = Jason::Spec.new(type: type)
        expect(spec).to be_fits(true)
        expect(spec).to be_fits(false)
      end
    end

    it "Matches by class" do
      spec = Jason::Spec.new(type: Jason::Spec)
      expect(spec).to be_fits(spec)
    end
  end

  describe "Size" do
    it "takes a size spec" do
      spec = Jason::Spec.new(size: 1)
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: size")
    end

    it "takes a fixnum for size" do
      spec = Jason.spec(size: 1)
      expect(spec).to_not be_fits( [ ] )
      expect(spec).to     be_fits( [ 1 ] )
    end

    it "takes a range for size" do
      spec = Jason.spec(size: 1..3)
      expect(spec).to     be_fits( [ 1 ] )
      expect(spec).to     be_fits( [ 1, 2 ])
      expect(spec).to_not be_fits( [ ] )
      expect(spec).to_not be_fits( [ 1, 2, 3, 4 ] )
    end

    it "takes an array (as a range) for size" do
      spec = Jason.spec(size: [ 1, 3, 5 ])
      expect(spec).to     be_fits( [ 1 ] )
      expect(spec).to_not be_fits( [ 1, 2 ] )
      expect(spec).to     be_fits( [ 1, 2, 3 ] )
    end

    it "matches hashes by key size" do
      spec = Jason::Spec.new(size: 1)
      expect(spec).to_not be_fits({ a: 1, b: 2 })
      expect(spec).to     be_fits({ c: 3 })
    end
  end

  describe "Each" do
    it "takes an each spec" do
      spec = Jason.spec(each: [ :id ])
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: each")
    end

    it "checks that each item in the array matches" do
      spec = Jason.spec(each: [ :id ])
      expect(spec).to     be_fits([ { 'id' => 1 }, { 'id' => 2 } ])
      expect(spec).to_not be_fits([ { 'id' => 1 }, { 'uid' => 2 } ])
    end
  end

  describe "Complex each structures" do
    it "should match hash structures" do
      spec = Jason.spec(each: { item: [ :id, :name ], link: [ :href ] })
      res = spec.fits?([ { "item" => {  "id" => 1, "name" => "Jason" }, "link" => { "href" => "file:///" } } ] )

      $stderr.puts spec.misses
      expect(res).to be true

      expect(spec).to_not be_fits( [ { "item" => {  "nid" => 1, "fame" => "Jason" }, "link" => { "href" => "file:///" } } ] )
    end

    it "should match deep hash structures"
    it "should match Jason::Spec"
  end

  describe "Any" do
    it "takes an any spec" do
      spec = Jason.spec(any: [ :id ])
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: any")
    end

    it "checks if there is at least one item in the array that match" do
      spec = Jason.spec(any: [ :id ])
      expect(spec).to     be_fits([ { 'id' => 1 }, { 'id' => 2 } ])
      expect(spec).to     be_fits([ { 'id' => 1 }, { 'uid' => 2 } ])
      expect(spec).to_not be_fits([ { 'uid' => 1 }, { 'uid' => 2 } ])
    end
  end

  describe "None" do
    it "takes a none spec" do
      spec = Jason.spec(none: [ :id ])
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: none")
    end

    it "checks if there are no items in the array that match" do
      spec = Jason.spec(none: [ :id ])
      expect(spec).to_not be_fits([ { 'id' => 1 }, { 'id' => 2 } ])
      expect(spec).to_not be_fits([ { 'id' => 1 }, { 'uid' => 2 } ])
      expect(spec).to     be_fits([ { 'uid' => 1 }, { 'uid' => 2 } ])
    end
  end

  describe "Fields" do
    it "takes a fields spec" do
      spec = Jason.spec(fields: [ :id ])
      spec.fits?(:x)
      expect(spec.misses).to_not include("Unknown spec: fields")
    end

    it "checks if all the provided fields are in the hash" do
      spec = Jason.spec(fields: [ :a, :b, :c ])
      expect(spec).to_not be_fits({ 'd' => 1 })
      expect(spec).to_not be_fits({ 'b' => 1 })
      expect(spec).to     be_fits({ 'a' => 1, 'b' => 2, 'c' => 3 })
    end

    it "checks each" do
      spec = Jason.spec(fields: { each: [ :a, :b, :c ] })
      expect(spec).to_not be_fits({ 'd' => 1 })
      expect(spec).to_not be_fits({ 'b' => 1 })
      expect(spec).to     be_fits({ 'a' => 2, 'b' => 2, 'c' => 3 })
    end

    it "checks any" do
      spec = Jason.spec(fields: { any: [ :a, :b, :c ] })
      expect(spec).to     be_fits({ 'b' => 1 })
      expect(spec).to     be_fits({ 'a' => 1, 'c' => 3 })
      expect(spec).to_not be_fits({ 'd' => 1 })
    end

    it "checks none" do
      spec = Jason.spec(fields: { none: [ :a, :b, :c ] })
      expect(spec).to_not be_fits({ 'b' => 1 })
      expect(spec).to_not be_fits({ 'a' => 1, 'b' => 2, 'c' => 3 })
      expect(spec).to be_fits({ 'd' => 1 })
    end
  end
end
