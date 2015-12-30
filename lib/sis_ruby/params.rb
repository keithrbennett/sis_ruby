module SisRuby
class Params

  # These methods behave as simple accessors when called with no arguments.
  # When called with an argument, that argument is used to set the value corresponding to the method name.

  # The conventional 'attribute=' method forms for this class are supported
  # in addition to the methods below, as an alternate way to set values.

  attr_writer :fields, :filter, :limit, :offset, :sort

  def fields(*args)
    if args.none?
      return @fields
    elsif args.one?
      @fields = Array(args.first)
    else
      @fields = args
    end
    @fields = @fields.to_set  # order shouldn't matter, and no dups
    self
  end


  def filter(*args)
    if args.any?
      @filter = args.first
      self
    else
      @filter
    end
  end


  def limit(*args)
    if args.any?
      @limit = args.first
      self
    else
      @limit
    end
  end


  def offset(*args)
    if args.any?
      @offset = args.first
      self
    else
      @offset
    end
  end


  def sort(*args)
    if args.any?
      @sort = args.first
      self
    else
      @sort
    end
  end


  def to_hash
    h = {}
    h['limit'] = limit if limit
    h['offset'] = offset if offset
    h['fields'] = fields.to_a.join(',') if fields
    h['q'] = filter if filter
    h['sort'] = sort if sort
    h
  end


  def self.from_hash(other)
    instance = self.new
    instance.limit(other['limit']) if other['limit']
    instance.fields(other['fields'].split(',').to_set) if other['fields']
    instance.offset(other['offset']) if other['offset']
    instance.filter(other['q']) if other['q']
    instance.sort(other['sort']) if other['sort']
    instance
  end


  def clone
    other = Params.new
    other.limit(self.limit)         if self.limit
    other.fields(self.fields.clone) if self.fields
    other.offset(self.offset)       if self.offset
    other.filter(self.filter.clone) if self.filter
    other.sort(self.sort)           if self.sort
    other
  end


  def to_h
    to_hash
  end


  def hash
    to_h.hash
  end


  def ==(other)
    other.is_a?(self.class) && other.to_h == self.to_h
  end


  def <=>(other)
    self.to_h <=> other.to_h
  end
end
end
