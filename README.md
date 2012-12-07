# Typograf

Universal tool for preparing russian text for web publishing. Ruby wrapper for typograf.ru webservice

## Installation

Add this line to your application's Gemfile:

    gem 'typograf'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typograf

## Usage

```ruby
require "typograf"

Typograf.process('text')
```

You can pass second argument - hash of options.

### Default options

```ruby
{
  :tags => 1, # 0 — не расставлять; 1 — расставлять
  :tags_delete => 0, # 0 — не удалять; 1 — удалять до типографирования; 2 — удалять после типографирования
  :paragraph => {
    :insert => 1, # 1 — ставить; 0 — не ставить
    # теги задают внешний вид обрамления параграфа, начальные и конечные теги соответственно (могут быть пустыми)
    :start => '<p>',
    :end => '</p>'
  },
  :newline => {
    :tag => '<br/>',  # теги перевода строки.
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
  :symbols => 0, # как выводить типографированный текст: 0 — буквенными символами (&nbsp;); 1 — числовыми (&#160;); 2 - просто символами
  # добавляет дополнительные атрибуты к ссылкам
  :link => {
    :target => '',
    :class => ''
  }
}
```

## TODO
 - refactor options (do not use nested options; use symbols instead of "magic" numbers)
 - support ruby 1.8 (`encode` missing)
 - implement missing specs

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
