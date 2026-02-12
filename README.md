# Assetto Corsa EVO — русская локализация

Полный русский перевод интерфейса Assetto Corsa EVO: меню, настройки машины на трассе, настройки графики, подсказки и опции тюнинга автомобилей.

---

## Установка в один клик

1. Скачайте архив репозитория (Code → Download ZIP) и распакуйте.
2. **Запустите `install.bat`** от имени администратора не обязательно, но папка игры не должна быть только для чтения.
3. Скрипт сам найдёт игру в стандартной папке Steam. Если игра стоит в другом месте — введите путь по запросу.
4. В игре: **Настройки → Общие → Язык → Русский**.

После этого интерфейс будет на русском.

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

При выходе обновлений игры часть строк может снова стать на английском. Следите за обновлениями репозитория: новые версии файлов можно установить повторным запуском `install.bat` (файлы будут перезаписаны).

---

## Лицензия и благодарности

Локализация сделана для сообщества. Игра — Assetto Corsa EVO, автор игры — Kunos Simulazioni.  
Если перевод помог вам комфортнее играть — поделитесь ссылкой с друзьями. Хорошей езды.
