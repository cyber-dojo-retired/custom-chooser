# frozen_string_literal: true

class Chooser

  def initialize(externals)
    @externals = externals
  end

  def alive?
    true
  end

  def ready?
    services = []
    services << creator
    services << custom_start_points
    services.all?{ |service| service.ready? }
  end

  def sha
    ENV['SHA']
  end

  def display_names
    custom_start_points.display_names
  end

  def create_custom_group(display_names:)
    creator.create_custom_group(display_names)
  end

  def create_custom_kata(display_name:)
    creator.create_custom_kata(display_name)
  end

  private

  def creator
    @externals.creator
  end

  def custom_start_points
    @externals.custom_start_points
  end

end
