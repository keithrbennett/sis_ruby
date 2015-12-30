require_relative 'spec_helper'

module SisRuby

describe Params do

  it 'results in an empty hash when nothing is set' do
    expect(Params.new.to_hash).to eq({})
  end

  it 'correctly concatenate fields' do
    fields = %w(foo bar).to_set
    params = Params.new.fields(fields)
    expect(params.fields).to eq(fields)
    expect(params.to_hash).to eq({ 'fields' => 'foo,bar'})
  end

  it 'sets limit correctly' do
    params = Params.new.limit(3)
    expect(params.limit).to eq(3)
    expect(params.to_hash).to eq({ 'limit' => 3 })
  end

  it 'sets offset correctly' do
    params = Params.new.offset(4)
    expect(params.offset).to eq(4)
    expect(params.to_hash).to eq({ 'offset' => 4 })
  end

  it 'sets filter correctly' do
    filter = { 'my_numeric_field' => { '$gt' => 10 }}
    params = Params.new.filter(filter)
    expect(params.filter).to eq(filter)
    expect(params.to_hash).to eq({ 'q' => filter })
  end

  it 'sets sort correctly' do
    params = Params.new.sort('-count')
    expect(params.sort).to eq('-count')
    expect(params.to_hash).to eq({ 'sort' => '-count' })
  end

  specify 'to_h and to_hash return equal hashes' do
    params = Params.new.sort('-count')
    expect(params.to_h).to eq(params.to_hash)
  end

  specify '2 identical objects are ==, and <=> returns 0' do
    params1 = Params.new.sort('-count')
    params2 = Params.new.sort('-count')
    expect(params1).to eq(params2)
    expect(params1 <=> params2).to eq(0)
  end

  specify '2 different objects are not ==, and <=> returns non-0' do
    params1 = Params.new.sort('-count')
    params2 = Params.new.sort('-date')
    expect(params1).not_to eq(params2)
    expect(params1 <=> params2).not_to eq(0)
  end


  specify 'clone returns an equal copy' do
    params_orig = Params.new.sort('-count').limit(300).filter({key: 'value'}).offset(100).fields('a', 'b')
    params_clone = params_orig.clone
    expect(params_clone).to eq(params_orig)
  end

  specify 'from_hash returns an equal copy' do
    params_orig = Params.new.sort('-count').limit(300).filter({key: 'value'}).offset(100).fields('a', 'b')
    params_copy = Params.from_hash(params_orig.to_hash)
    expect(params_copy).to eq(params_orig)
  end
end
end
