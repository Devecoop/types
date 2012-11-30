class PropertySerializer < ApplicationSerializer
  cached true

  attributes :uri, :id, :name, :default, :values, :created_at, :updated_at

  def uri
    PropertyDecorator.decorate(property).uri
  end
end