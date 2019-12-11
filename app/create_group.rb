# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'json_plain'
require_relative 'saver_asserter'

module CreateGroup

  include IdPather
  include SaverAsserter

  def create_group(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).group_id
    saver_assert_batch(
      group_manifest_write_cmd(id, json_plain(manifest)),
      group_katas_write_cmd(id, '')
    )
    id
  end

  def group_manifest_write_cmd(id, manifest_src)
    ['write', group_manifest_filename(id), manifest_src]
  end

  def group_manifest_filename(id)
    group_id_path(id, 'manifest.json')
  end

  def group_katas_write_cmd(id, src)
    ['write', group_katas_filename(id), src]
  end

  def group_katas_filename(id)
    group_id_path(id, 'katas.txt')
  end

end
