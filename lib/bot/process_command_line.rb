# frozen_string_literal: true

class Bot::ProcessCommandLine
  def call(*params)
    case params[0]
    when 'video_alarm'
      { text: LOCALE['alarm']['video'] }
    end
  end
end
