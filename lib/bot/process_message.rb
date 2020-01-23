# frozen_string_literal: true

class Bot::ProcessMessage
  def call(text)
    if text == LOCALE['commands']['show_cameras']
      { text: 'Camera Snapshot' }
    else
      { text: LOCALE['messages']['did_not_understand'] }
    end
  end
end
