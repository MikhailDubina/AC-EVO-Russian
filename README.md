# Assetto Corsa EVO — русская локализация

Полный русский перевод интерфейса Assetto Corsa EVO: меню, настройки машины на трассе, настройки графики, подсказки и опции тюнинга автомобилей.

**Важно:** в игре изначально нет русского в меню. Установщик копирует переводы и добавляет пункт «Русский» в настройки (патч `patch_ru.ps1` — без него язык не выбрать). Затем в игре: Настройки → Язык → Русский.

---

## Установка

1. Скачайте архив (Code → Download ZIP) и **распакуйте целиком** (папка `localization` и `install_ru.bat`).
2. **Запустите `install_ru.bat`** — откроется окно (оно не закроется само), скрипт найдёт игру, скопирует переводы и применит патч. Если игра не в стандартной папке Steam — введите путь по запросу.
3. В игре: **Настройки → Общие → Язык → Русский**.

**Если в архиве нет папки `localization` с файлами `ru.loc`** — распакуйте заново или при OneDrive: правый клик по `localization` → «Всегда сохранять на этом устройстве».

---

## Что переведено

- Главное меню (Вождение, Автомобили, Академия, Пилот, Галерея, Настройки)
- Подсказки ко всем кнопкам меню
- Разделы «Мои автомобили», «Автоцентр», «Тюнинг»
- Настройка машины на трассе: шины, подвеска, амортизаторы, аэродинамика, электроника, топливо и стратегия, все подсказки
- Настройки графики (видео): все пункты и подсказки
- Опции тюнинга автомобилей (более 2000 строк)
- Тексты без переносов посередине слов (где это задаётся стилями)

---

## Шрифт и переносы (опционально)

Если при выборе русского языка **вместо букв отображаются квадраты** или **слова в меню переносятся посередине** (например, «АВТОМО» и «БИЛИ» на двух строках), можно добавить в стили игры поддержку кириллицы и отключение переноса.

Папка игры: там, где лежит `Assetto Corsa EVO.exe`.  
Нужно отредактировать два файла в папке `uiresources\css\`:

- `ui.css`
- `uicomponents.css`

Перед правкой сделайте копии файлов (например, `ui.css.bak`).

### 1. Файл `ui.css`

В **конец** файла добавьте:

```css
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-regular.ttf');
  font-weight: 400;
}
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-medium.ttf');
  font-weight: 500;
}
@font-face {
  font-family: 'roboto';
  src: url('/fonts/roboto-bold.ttf');
  font-weight: 600;
}
html[lang="ru"]:root {
  --font-family-main: 'roboto';
  overflow-wrap: break-word;
}
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic,
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic > div {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
```

### 2. Файл `uicomponents.css`

В **конец** файла добавьте:

```css
html[lang="ru"]:root {
  --font-family-main: 'roboto';
  overflow-wrap: break-word;
}
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic,
html[lang="ru"] ks-page-main #panelMenu ks-btnbasic > div {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
html[lang="ru"] ks-page-paintshop .paintshop-body .row.controls .categoryselector .category span.label {
  white-space: nowrap;
  overflow-wrap: normal;
  word-break: normal;
}
```

Шрифты `roboto-regular.ttf`, `roboto-medium.ttf`, `roboto-bold.ttf` должны лежать в папке игры в `uiresources\fonts\` (в стандартной установке они уже есть).

---

## Требования

- **Assetto Corsa EVO** (Steam).
- В игре должен быть выбран язык **Русский** (Настройки → Общие → Язык).

---

## Обновление локализации

При выходе обновлений игры: (1) часть строк может снова стать на английском — запустите заново `install_ru.bat`; (2) обновление может перезаписать `components.js`, и пункт «Русский» пропадёт из меню — тогда снова запустите `install_ru.bat` (он применит патч автоматически).

---

## Лицензия и благодарности

Локализация сделана для сообщества. Игра — Assetto Corsa EVO, автор игры — Kunos Simulazioni.  
Если перевод помог вам комфортнее играть — поделитесь ссылкой с друзьями. Хорошей езды.
