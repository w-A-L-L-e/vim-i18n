# vim-i18n

Automated translation of Ruby/Rails projects extended to also work in Vue.js frontend source files

Modified by Walter Schreppers to also work for translations in .vue javascript templates.

It now also saves to /src/locales/nl.json or en.json and makes a snippit compatible
with vue-i18n whenever the filename is .js or .vue.

Instead of the ruby version
```
<%= t('key') %>
```
it now inserts: 
```
{{ $t('key') }} 
```
in the vue application view code and $t('key') in js files.

After this, the original string is inserted into the locales/nl.json file or the path
you supply when first calling I18nTranslateString.


## Introduction

`vim-i18n` helps you translate your Ruby/Rails project. It just exposes a
single function, `I18nTranslateString`. This function takes the current visual
selection, converts it into a `I18n.t()` call, and adds the proper key in a
specified YAML store.

## Examples

### Extracting translations in `.html.erb` files

```
# app/views/users/show.html.erb
<dt>Name</dt>
    ^^^^
    -> Visual select and `:call I18nTranslateString()`
```

You will be asked for a key. In keeping with Rails translation syntax, if the
key begins with `.` it will be considered a relative key:

```
# app/views/users/show.html.erb
<dt><%= t('.name') %>

# config/locales/en.yml

en:
  users:
    show:
      name: Name
```

### Extracting translations in `.rb` files

Say you have the following line in your codebase:

```
# app/controllers/static_controller.rb
@some_text = "Hello, %{name}!"
             ^^^^^^^^^^^^^^^^^
             -> Visual select this text and `:call I18nTranslateString()`
```

The plugin will first ask you for the I18n key to use (ie. `homepage.greeting`).
Then, if still not specified, the plugin will ask you the location of the YAML
store (ie. `config/locales/en.yml`).

At this point, the plugin will replace the selection, and add the string to the
YAML store:

```
# app/controllers/static_controller.rb
@some_text = I18n.t('homepage.greeting', name: '')
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
             -> BOOM!

# config/locales/en.yml
---
en:
  homepage:
    title: "Hello, %{name}!"
```

Note that the extracted translation included the appropriate interpolation.

### Displaying translation for the key

Let say you have the following key within view / model / controller:

```
# app/controllers/static_controller.rb
@some_text = I18n.t('homepage.greeting', name: '')
                     ^^^^^^^^^^^^^^^^^
```

After selecting and executing `I18nDisplayTranslation()`, the plugin will return you value for the translation.

## Vim mapping

Add this line or a simliar one to your `~.vimrc`:

```vim
vmap <Leader>z :call I18nTranslateString()<CR>
vmap <Leader>dt :call I18nDisplayTranslation()<CR>
```

For me however the above didn't seem to work. I used this as mapping:
```
vmap <C-S> :call I18nTranslateString()<CR>
vmap <C-Y> :call I18nDisplayTranslation()<CR>
```
## Installation

Install via [pathogen.vim](https://github.com/tpope/vim-pathogen), simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/stefanoverna/vim-i18n.git
