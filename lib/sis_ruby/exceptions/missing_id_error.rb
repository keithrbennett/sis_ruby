module SisRuby
class MissingIdError < RuntimeError

  def initialize(id_field_name)
    @id_field_name = id_field_name
  end

  def to_s
    "Missing required id field #{@id_field_name}}"
  end
end
end