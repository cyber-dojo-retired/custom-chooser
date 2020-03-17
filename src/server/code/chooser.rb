# frozen_string_literal: true

class Chooser

  def initialize(externals)
    @externals = externals
  end

  def alive?
    true
  end

  def ready?
    [creator,custom_start_points].all?(&:ready?)
  end

  def sha
    ENV['SHA']
  end

  def manifests
    custom_start_points.manifests
  end

  def group_create_custom(display_names:)
    creator.group_create_custom(display_names)
  end

  def kata_create_custom(display_name:)
    creator.kata_create_custom(display_name)
  end

  private

  def creator
    @externals.creator
  end

  def custom_start_points
    @externals.custom_start_points
  end

end
