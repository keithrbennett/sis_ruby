require_relative 'spec_helper'

describe HashBuilder do

  PERMITTED_ENTITY_ENDPOINT_TOP_LEVEL_KEYS = %w(
      fields
      id
      limit
      offset
      q
  )

  QUERY_HASH = {
      'environment'  => 'prod',
      'status'       => 'live',  # not maintenance
      'role.product.name' => 'mdns',
  }

  specify 'will create a limit key/value pair correctly' do
    builder = HashBuilder.new
    expect(builder.limit(10).to_h).to eq({ 'limit' => 10 })
  end

  specify 'subsequent calls will replace an existing value' do
    builder = HashBuilder.new
    builder.limit(10)
    expect(builder.limit(11).to_h).to eq({ 'limit' => 11 })
  end

  specify 'a query hash will be correctly inserted' do
    builder = HashBuilder.new
    builder.q(QUERY_HASH)
    expect(builder.to_h).to eq({ 'q' => QUERY_HASH})
  end

  specify '2 key/value pairs are no problem' do
    builder = HashBuilder.new
    builder.q(QUERY_HASH).limit(20)
    expect(builder.to_h).to eq({ 'q' => QUERY_HASH, 'limit' => 20 })
  end

  specify 'keys are all Strings when key type of String is specified' do
    builder = HashBuilder.new(String)
    expect(builder.foo(1).bar(2).to_h.keys.all? { |key| key.is_a?(String) }).to eq(true)
  end

  specify 'keys are all Symbols when key type of Symbol is specified' do
    builder = HashBuilder.new(Symbol)
    expect(builder.foo(1).bar(2).to_h.keys.all? { |key| key.is_a?(Symbol) }).to eq(true)
  end

  specify 'respond_to_missing? always returns true' do
    builder = HashBuilder.new
    random_name = 'x' + Random.rand(1_000_000).to_s
    expect(builder.respond_to?(random_name, false)).to eq(true)
  end

  # Disable permitted methods feature for now; it was not fully implemented,
  # and should be a predicate lambda rather than an array anyway.

  # context 'permitted methods' do
  #
  #   specify 'when not specified, all are allowed' do
  #     builder = HashBuilder.new
  #     expect(builder.respond_to?('foo')).to eq(true)
  #   end
  #
  #   specify 'when empty, none are allowed' do
  #     builder = HashBuilder.new(String, [])
  #     expect(builder.new(String).respond_to?('foo')).to eq(false)
  #     builder.something(123)
  #     expect { builder.something(123) }.to raise_error
  #   end
  #
  #   specify 'when non-empty, only permitted are permitted' do
  #     builder = HashBuilder.new(String, [:foo])
  #     expect(builder.new(String).respond_to?('foo')).to eq(true)
  #     expect(builder.new(String).respond_to?('bar')).to eq(false)
  #
  #   end
  # end
end

