# frozen_string_literal: true

require_relative './bot/process_command_line'
require_relative './bot/process_message'

class Bot
  def run
    Telegram::Bot::Client.run(CONFIG['telegram_bot_api_token'], logger: Logger.new($stdout)) do |bot|
      begin
        if ARGV[0] && !ARGV[0].empty?
          process_command_line(bot)
        else
          listen(bot)
        end
      rescue Telegram::Bot::Exceptions::ResponseError => e
        if e.error_code.to_s == '502'
          bot.logger.error 'telegram stuff, nothing to worry!'
          retry
        end
      end
    end
  end

  def process_command_line(bot)
    message_opts = Bot::ProcessCommandLine.new.call(*ARGV)
    CONFIG['notify_telegram_ids'].each do |chat_id|
      bot.api.sendMessage message_opts.merge(chat_id: chat_id)
    end
  end

  def listen(bot)
    bot.listen do |message|
      next unless CONFIG['allowed_telegram_ids'].include?(message.chat.id)

      case message.text
      when '/start'
        opts = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: ['покажи камеры'],
                                                             one_time_keyboard: true)
        bot.api.send_message chat_id: message.chat.id, text: LOCALE['start'], reply_markup: opts
      else
        process_message(bot, message)
      end
    end
  end

  def process_message(bot, message)
    message_opts = Bot::ProcessMessage.new.call(message.text)
    bot.api.send_message message_opts.merge(chat_id: message.chat.id)
  end
end
