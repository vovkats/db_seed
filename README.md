DbSeed
======

Зачем это нужно
---------------

Gem `db_seed` позволяет создавать и выполнять миграции данных,
хранимые в отдельной от миграций схемы папке `db/seed`.

Как этим пользоваться
---------------------

Чтобы начать пользоваться гемом,
его необходимо добавить в `Gemfile` и
выполнить `bundle install`.

Чтобы создать новую миграцию данных
необходимо выполнить команду
`$ rails g seed migration_name`,
где `migration_name` - имя миграции, которую нужно создать.

После этого нужно отредактировать созданный генератором файл
в папке `db/seed`. Все изменения, которые должны произойти
с данными, необходимо описать в методе `MigrationName#change`.

Кроме обычных способов работы с моделями, доступен метод `#say(message)`,
который выведет в консоль дополнительное отладочное сообщение.

Выполнение миграций производится `rake`-задачей `db:seed:apply`,
либо, если нужно сначала выполнить все миграции схемы,
а затем выполнить миграции данных, нужно запустить задачу
`db:migrate:seed`.

Настройки
---------

Настроить логгер и отображение процесса миграции данных
можно, добавив файл `config/initializers/dbseed.rb`, например,
следующего содержания:

```
YourApp::Application.config.tap do |config|
  logger = Logger.new("log/db_seed.log")
  logger.formatter = -> (lvl, time, name, msg) {
    "%s -- [%-5s]: %s\n" % [time.strftime("%Y.%m.%d %H:%M"), lvl, msg]
  }

  logger.level = Logger::ERROR

  config.assets[:db_seed] = {
    verbose: true,         # true - отображать процесс выполнения
    logger: logger         # По умолчанию будет взят Logger.new("log/db_seed.log"), без форматтера
  }
end
```

Чтобы ещё немного упростить процесс настройки, добавлен генератор `seed:initializer`,
который добавляет файл `config/initializers/dbseed.rb` с таким же, примерно, кодом.
