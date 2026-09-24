# Кастомные патчи для Nova Video Player (aos-AVP)

В этой папке сохранены все доработки и исправления для быстрого накатывания на любую новую версию Nova Video Player.

## Список патчей

### 1. `patches/01_medialib.patch` (MediaLib)
- **Исправление краша плеера при открытии видео (`MediaMetadata.checkType` и `ISO639codes`)**:
  - `IMediaPlayer.java` и `IMediaMetadataRetriever.java`: шаг смещения аудиодорожек (`METADATA_KEY_AUDIO_TRACK_MAX = 9`, `DISPOSITION = 8`) и субтитров (`METADATA_KEY_SUBTITLE_TRACK_MAX = 6`, `DISPOSITION = 5`) приведены в точное соответствие со скомпилированной нативной библиотекой `libavos.so`.
  - `ISO639codes.java`: защита `getEnglishLanguageNameForLetterCode` от `IllformedLocaleException` при некорректных кодах языка.
  - `MediaMetadata.java`: безопасные `getInt`, `getString`, `getBoolean` без падения приложения с `IllegalStateException: Wrong type 2 but got 1`.
  - `LibAvos.java`: защита от `UnsatisfiedLinkError` для методов аудио, если они отсутствуют в нативной библиотеке.
- **Интеграция TorrServe Matrix (ExternalBookmarks)**:
  - `ExternalBookmarks.java`: модуль для сохранения и восстановления позиций воспроизведения торрентов из TorrServe Matrix (`/torrents` API).
  - `IndexHelper.java`: перехват загрузки и сохранения закладок для неиндексированных сетевых URI из TorrServe.
- **Ремаппинг путей в базе данных (`VideoOpenHelper.java`)**:
  - Автоматическая замена устаревших путей пакетов в `media.db` при открытии базы.
- **Улучшения скрапера и распознавания файлов**:
  - `TransliterateUtils.java` и `TransliterateUtilsTest.java`: алгоритмическая обратная транслитерация русских названий фильмов и сериалов, написанных латиницей (например, `Kholop` -> `Холоп`, `Brat 2` -> `Брат 2`).
  - `ParseUtils.java`:
    - `splitBilingualTitle`: алгоритмическое разбиение склеенных русско-английских названий (например, `01.Назад.в.будущее.Back.to.the.Future.1985`) на отдельные части для поиска в TMDb.
    - `LEADING_NUMBERING`: корректное отсечение ведущих номеров дорожек и серий без пробела (`01.Назад`) с сохранением названий вида `3.10 to Yuma`, `2 Guns`.
    - `GARBAGE_LOWERCASE`: расширен список мусорных релизных токенов (`hddvdrip`, `webdl`, `telecine`, `telesync`, `camrip`).
  - `MovieScraper3.java` и `ShowScraper4.java`: раздельный поиск кандидатов для двуязычных названий, транслитерированных названий и учет в Unified Scoring (`LevenshteinDistance`).
  - `SearchShow.java`: фоллбэк скрапера сериалов на транслитерированное название.

### 2. `patches/02_video.patch` (Video)
- **Фоновый онлайн-скрапинг TMDb для всех источников (TorrServe, Samba, WebDAV, локальные файлы)**:
  - Автоматический поиск и подтягивание метаданных (название, постер, год, описание) во время воспроизведения любого неиндексированного видеопотока.
  - Мгновенное обновление OSD при получении результатов из TMDb.
- **Отображение качества видео (бейдж разрешения) в OSD**:
  - `PlayerActivity.java`: динамическое определение параметров видеопотока и добавление бейджа разрешения (`[4K]`, `[1080p]`, `[720p]`, `[SD]`) к заголовку в инфопанели OSD.
- **Поддержка M3U/M3U8 плейлистов**:
  - `M3uParser.java` и `M3uParserTest.java`: парсер плейлистов с поддержкой локальных и удаленных потоков.
  - `PlayerActivity.java`: отображение заголовков и имен серий из плейлистов и внешних URI.
- **Переключение серий и видео кнопками пульта**:
  - `PlayerActivity.java`: перехват клавиш пульта **Channel Up/Down** (`KEYCODE_CHANNEL_UP`/`DOWN`), **Page Up/Down**, **Next/Prev Track** (`KEYCODE_MEDIA_NEXT`/`PREVIOUS`), а также букв **G / H** на клавиатуре для перехода к следующему / предыдущему видео или серии.
  - `PlayerService.java` и `UpdateNextTask.java`: логика определения следующего и предыдущего файла в папке/плейлисте и переключения воспроизведения на лету без закрытия плеера.
- **Настраиваемый шаг перемотки (2, 5, 10, 15, 20, 30, 60 сек)**:
  - `res/values/arrays.xml`: массивы доступных секунд шага перемотки.
  - `res/values/strings.xml` и `res/values-ru/strings.xml`: названия и локализации настройки.
  - `res/xml/preferences_video.xml`: пункт меню в настройках видео.
  - `PlayerController.java` и `PlayerActivity.java`: чтение пользовательской настройки `seek_step` вместо жестко зашитых 10 секунд.
- **Затемнение экрана на паузе и заставка (OLED screensaver)**:
  - `res/layout/player.xml`: оверлей затемнения `screensaver_overlay` с плавающими часами `screensaver_clock`.
  - `res/values/arrays.xml`: интервалы таймаута бездействия (Отключено, 1, 5, 10, 15, 30 мин).
  - `res/values/strings.xml` и `res/values-ru/strings.xml`: названия и локализации настройки затемнения.
  - `res/xml/preferences_video.xml`: пункт меню в настройках видео («Затемнять экран на паузе»).
  - `PlayerActivity.java`: плавное включение полупрозрачного затемнения и перемещение часов по экрану для защиты OLED от выгорания, автоматический выход при любом нажатии кнопок или касании экрана.
- **Безопасность плеера и импорт**:
  - `VideoMetadata.java`: защита `getMetadataInt/Bool/String` от сбоев чтения метаданных.
  - `PlayUtils.java`: сохранение позиции при остановке воспроизведения внешних видео.
  - `MediaLibraryBackupService.java`: автоматический ремаппинг путей в базе при импорте бэкапа.
  - `build.gradle`: поддержка `signingConfig.debug` при сборке релизного APK без файла секретных ключей.

### 3. `patches/03_root_core_mk.patch` (Корень проекта)
- Исправление путей Windows (обратные слэши `\`) при вызове `make` и сборке компонентов.

### 4. `patches/04_filecorelibrary.patch` (FileCoreLibrary)
- **Очистка URL-параметров при извлечении имени файла и расширения (`FileUtils.java`)**:
  - `stripExtensionFromName` и `getName`: корректное отсечение query-параметров (`?key=value`) и фрагментов (`#...`) из имен потоковых ссылок (TorrServe, AceStream, прямые HTTP/HTTPS потоки).
  - Предотвращает поломку определения расширений (`.mkv`, `.mp4`), субтитров и парсинга названий при воспроизведении ссылок вида `http://.../stream/video.mkv?play`.

### 5. `patches/05_native_avos.patch` (Нативный движок воспроизведения native/avos)
- **Устранение зависания видео и эффекта «убыстренной перемотки» при медленной сети/раздаче**:
  - `Source/stream_parser_ffmpeg.c`: симметричная проверка `video_starved` в демуксере FFmpeg. Демуксер больше не засыпает, когда очередь звука заполнена, а видео голодает — чтение пакетов видео из сети продолжается непрерывно.
  - `Source/stream_sync.c`: защитный шлюз ухода звука вперед (`stream_sync_pcm_audio_lead_gate`) с порогом 500 мс для режима Mode 2 passthrough, не позволяющий звуку убегать на секунды вперед при застывшем видеопотоке.
  - `Source/stream_sink_video_android3.c`: непрерывный сброс сильно отставших кадров (`< -200 мс`) без периодического принудительного вывода на экран без задержки.
- **Симметричная пересинхронизация после паузы (Pause / Resume)**:
  - `Source/codec_sfdec2.c`: в `sfdec2_android_sync_on_pause_locked` проверка рассинхрона расширена на `abs(video_time - audio_time) > 500`. Если пауза была нажата при задержке видео (звук впереди), якоря таймингов полностью сбрасываются и плеер пересинхронизируется по первому воспроизведенному кадру, предотвращая возникновение постоянного рассинхрона.


---

## Как обновить Nova на новую версию

Когда выходит новая версия (например, через `git pull` или переключение на новый тег/ветку):

1. Перейдите в корень репозитория `aos-AVP`.
2. Запустите скрипт применения патчей:
   ```powershell
   .\apply_patches.ps1
   ```
   *(или в bash: `./apply_patches.sh`)*

3. Соберите APK:
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
   $env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
   $env:ANDROID_SDK_ROOT = "$env:LOCALAPPDATA\Android\Sdk"
   $env:Path = "$env:JAVA_HOME\bin;C:\w64devkit\bin;$env:Path"
   cd Video
   .\gradlew.bat assembleNoamazonRelease
   ```

4. Готовый APK для ТВ (`armeabi-v7a`) появится в:
   `Video\build\outputs\apk\noamazon\release\`
