# encoding: utf-8
require 'net/http'
require 'htmlentities'

module Typograf
  class NetworkError < StandardError
    def initialize(message="", backtrace = nil)
      super(message)
      self.set_backtrace(backtrace) if backtrace
    end
  end

  class Client
    URL = 'http://www.typograf.ru/webservice/'
    DEFAULT_PREFERENCES = {
      :tags => 1, # 0 — не расставлять; 1 — расставлять
      :tags_delete => 0, # 0 — не удалять; 1 — удалять до типографирования; 2 — удалять после типографирования
      :paragraph => {
        :insert => 1, # 1 — ставить; 0 — не ставить
        # теги задают внешний вид обрамления параграфа, начальные и конечные теги соответственно (могут быть пустыми)
        :start => '<p>',
        :end => '</p>'
      },
      :newline => {
        :tag => '<br />',  # теги перевода строки.
        :insert => 1 # перевод строки: 1 — ставить; 0 — не ставить
      },
      :cms_new_line => 0, # Переводы строк <p>&nbsp;</p>
      :dos_text => 0, # удаляет одинарные переводы строк и переносы: 0 — не удалять; 1 — удалять
      :nowraped => {
        :insert => 1, # 1 — ставить; 0 — не ставить
        :nonbsp => 0, # 0 — не использовать неразрывные конструкции вместо (неразрывного пробела); 1 — наоборот
        :length => 0, # не объединять в неразрывные конструкции слова, написанные через дефис, с общей длинной больше N знаков. Если 0 то не используется
        :start  => '<nobr>',
        :end    => '</nobr>' 
      },
      :hanging_punct => 0, # висячая пунктуация: 1 — использовать; 0 — не использовать
      :hanging_line => 0, # висячие строки: 1 — удалять; 0 — не удалять
      :minus_sign => '&ndash;', # указывает какой символ использовать вместо знака минус: — &ndash; или &minus;
      :hyphen => {
        :insert => 0,
        :length => 0
      },
      :acronym => 1, # выделять сокращения: 1 — выделять; 0 — не выделять
      :symbols => 0, # как выводить типографированный текст: 0 — буквенными символами (&nbsp;); 1 — числовыми (&#160;)
      # добавляет дополнительные атрибуты к ссылкам
      :link => {
        :target => '',
        :class => ''
      }
    }

    def form_xml(options)
      o = options.dup

      o[:symbols] = 1 if o[:symbols] == 2

      xml = <<-XML_TEMPLATE
<?xml version="1.0" encoding="windows-1251" ?>
<preferences>
  <tags delete="#{o[:tags_delete]}">#{o[:tags]}</tags>
  <paragraph insert="#{o[:paragraph][:insert]}">
    <start><![CDATA[#{o[:paragraph][:start]}]]></start>
    <end><![CDATA[#{o[:paragraph][:end]}]]></end>
  </paragraph>
  <newline insert="#{o[:newline][:insert]}"><![CDATA[#{o[:newline][:tag]}]]></newline>
  <cmsNewLine valid="#{o[:cms_new_line]}" />
  <dos-text delete="#{o[:dos_text]}" />
      XML_TEMPLATE

      if o[:nowraped][:nonbsp] != 0
        xml = xml.chomp(" \n") + <<-XML_TEMPLATE
  <nowraped insert="#{o[:nowraped][:insert]}" nonbsp="#{o[:nowraped][:nobsp]}" length="#{o[:nowraped][:length]}">
    <start><![CDATA[#{o[:nowraped][:start]}]]></start>
    <end><![CDATA[#{o[:nowraped][:end]}]]></end>
  </nowraped>
      XML_TEMPLATE
      end

      xml = xml.chomp(" \n") + <<-XML_TEMPLATE
  <hanging-punct insert="#{o[:hanging_punct]}" />
  <hanging-line delete="#{o[:hanging_line]}" />
  <minus-sign><![CDATA[#{o[:minus_sign]}]]></minus-sign>
  <hyphen insert="#{o[:hyphen][:insert]}" length="#{o[:hyphen][:length]}" />
  <acronym insert="#{o[:acronym]}"></acronym>
  <symbols type="#{o[:symbols]}" />
  <link target="#{o[:link][:target]}" class="#{o[:link][:class]}" />
</preferences>
      XML_TEMPLATE

      xml.gsub(/^\s|\s$/, '')
    end

    def deep_merge(first, second)
      target = first.dup
      second.keys.each do |key|
        if second[key].is_a?(Hash) && target[key].is_a?(Hash)
          target[key] = deep_merge(target[key], second[key])
          next
        elsif second[key].is_a?(Hash) or target[key].is_a?(Hash)
          raise ArgumentError, "Can't merge hashes"
        end
        target[key] = second[key]
      end
      target
    end

    def initialize(options = {})
      @url = URI.parse(options.delete(:url) || URL)
      # @chr = options.delete(:chr) || 'UTF-8'
      @options = options
      @xml = if options.keys.length > 0
        form_xml( deep_merge(DEFAULT_PREFERENCES, options) )
      end
    end

    # Process text with remote web-service
    def send_request(text)
      params = {
        'text' => text.encode("cp1251"),
      }
      params['xml'] = @xml if @xml
      # params['chr'] = @chr if @chr
      params = URI.encode_www_form params
      request = Net::HTTP::Post.new(@url.path + '?' + params)

      begin
        response = Net::HTTP.new(@url.host, @url.port).start do |http|
          http.request(request)
        end
      rescue StandardError => exception
        raise NetworkError.new(exception.message, exception.backtrace)
      end

      if !response.is_a?(Net::HTTPOK)
        raise NetworkError, "#{response.code}: #{response.message}"
      end

      body = response.body.force_encoding("cp1251").encode("utf-8")

      # error = "\xCE\xF8\xE8\xE1\xEA\xE0: \xE2\xFB \xE7\xE0\xE1\xFB\xEB\xE8 \xEF\xE5\xF0\xE5\xE4\xE0\xF2\xFC \xF2\xE5\xEA\xF1\xF2"
      # error.force_encoding("ASCII-8BIT") if error.respond_to?(:force_encoding)
      if body == "Ошибка: вы забыли передать текст"
        raise NetworkError, "Ошибка: вы забыли передать текст"
      end

      if @options[:symbols] == 2
        HTMLEntities.new.decode(body.chomp)
      else
        body.chomp
      end
    end
  end
end
