# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'json_plain'
require_relative 'saver_asserter'

module CreateKata

  include IdPather
  include SaverAsserter

  def create_kata(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    event_summary = {
      'index' => 0,
      'time' => manifest['created'],
      'event' => 'created'
    }
    event0 = {
      'files' => manifest['visible_files']
    }
    saver_assert_batch(
      kata_manifest_write_cmd(id, json_plain(manifest)),
      kata_events_write_cmd(id, json_plain(event_summary)),
      kata_event_write_cmd(id, 0, json_plain(event0.merge(event_summary)))
    )
    id
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def kata_manifest_write_cmd(id, manifest_src)
    ['write', kata_manifest_filename(id), manifest_src]
  end

  def kata_manifest_filename(id)
    kata_id_path(id, 'manifest.json')
  end

  def kata_events_write_cmd(id, event0_src)
    ['write', kata_events_filename(id), event0_src]
  end

  def kata_events_filename(id)
    kata_id_path(id, 'events.json')
  end

  def kata_event_write_cmd(id, index, event_src)
    ['write', kata_event_filename(id,index), event_src]
  end

  def kata_event_filename(id, index)
    kata_id_path(id, "#{index}.event.json")
  end

end
