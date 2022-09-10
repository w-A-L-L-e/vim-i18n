let s:install_path=expand("<sfile>:p:h")

function! IsSyntaxRuby()
  let syntax = synIDattr(synID(line("'<"),col("'<"),1),"name")
  return match(syntax, "ruby")
endfunction

function! I18nTranslateString()
  " copy last visual selection to x register
  normal gv"xy
  let text = s:removeQuotes(s:strip(@x))
  let variables = s:findInterpolatedVariables(text)
  let key = s:askForI18nKey()
  if &filetype == 'eruby' || &filetype == 'eruby.html' || &filetype == 'slim' || &filetype == 'haml'
    let fullKey = s:determineFullKey(key)
    if IsSyntaxRuby() != -1
      let @x = s:generateI18nCall(key, variables, "t('", "')")
    else
      let @x = s:generateI18nCall(key, variables, "<%= t('", "') %>")
    endif
    call s:addStringToYamlStore(text, fullKey)
  elseif &filetype == 'vue'
    let @x = s:generateI18nCall(key, variables, "{{ $t('", "') }}")
    call s:addStringToLocaleJson(text, key)
  elseif &filetype == 'js'
    let @x = s:generateI18nCall(key, variables, "$t('", "')")
    call s:addStringToLocaleJson(text, key)
  else
    let @x = s:generateI18nCall(key, variables, "t('", "')")
    call s:addStringToYamlStore(text, key)
  endif
  " replace selection
  normal gv"xp
endfunction

function! I18nDisplayTranslation()
  normal gv"ay
  if &filetype == 'eruby' || &filetype == 'eruby.html' || &filetype == 'slim' || &filetype == 'haml'
    echom "Todo fix external ruby lookup script"
    " ruby get_translation(Vim.evaluate('@a'), Vim.evaluate('s:askForYamlPath()'))
  elseif &filetype == 'js' || &filetype == 'vue' 
    let selected_text = s:removeQuotes(s:strip(@a))
    let json_path = s:askForJsonPath()
    let cmd = s:install_path . "/lookup_json_key '" . json_path . "' '" . selected_text . "' "
    " echom is for short messages, but this is not always the case here
    echo "\n '" . selected_text . "' => " . system(cmd)
  endif
endfunction


function! s:addStringToLocaleJson(text,key)
  let json_path = s:askForJsonPath()
  let escaped_text = shellescape(a:text)
  let cmd = s:install_path . "/add_json_key '" . json_path . "' '" . a:key . "' " . escaped_text
  call system(cmd)
endfunction


function! s:removeQuotes(text)
  let text = substitute(a:text, "^[\\\"']", "", "")
  let text = substitute(text, "[\\\"']$", "", "")
  return text
endfunction

function! s:strip(text)
  return substitute(a:text, "^\\s*", "", "")
endfunction

function! s:findInterpolatedVariables(text)
  let interpolations = []
  " match multiple occurrences of %{XXX} and fill interpolations with XXX
  call substitute(a:text, "\\v\\%\\{([^\\}]\+)\\}", "\\=add(interpolations, submatch(1))", "g")
  return interpolations
endfunction

function! s:generateI18nCall(key, variables, pre, post)
  if len(a:variables) ># 0
    return a:pre . a:key . "', " . s:generateI18nArguments(a:variables) . a:post
  else
    return a:pre . a:key . a:post
  endif
endfunction

function! s:generateI18nArguments(variables)
  let arguments = []
  for interpolation in a:variables
    call add(arguments, interpolation . ": ''")
  endfor
  return join(arguments, ", ")
endfunction

function! s:askForI18nKey()
  call inputsave()
  let key = ""
  if exists('g:I18nKey')
    let key = g:I18nKey
  endif
  let key = input('I18n key: ', key)
  let g:I18nKey = key
  call inputrestore()
  return key
endfunction

function! s:determineFullKey(key)
  if match(a:key, '\.') == 0
    let controller = expand("%:h:t")
    let view = substitute(expand("%:t:r:r"), '^_', '', '')
    let fullKey = controller . '.' . view . a:key
    return fullKey
  else
    return a:key
  end
endfunction

function! s:addStringToYamlStore(text, key)
  let yaml_path = s:askForYamlPath()
  let escaped_text = shellescape(a:text)
  let cmd = s:install_path . "/add_yaml_key '" . yaml_path . "' '" . a:key . "' " . escaped_text
  call system(cmd)
endfunction

function! s:addStringToLocaleJson(text,key)
  let json_path = s:askForJsonPath()
  let escaped_text = shellescape(a:text)
  let cmd = s:install_path . "/add_json_key '" . json_path . "' '" . a:key . "' " . escaped_text
  call system(cmd)
endfunction

function! s:askForYamlPath()
  call inputsave()
  let path = ""
  if exists('g:I18nYamlPath')
    let path = g:I18nYamlPath
  else
    let path = input('YAML store: ', 'config/locales/en.yml', 'file')
    let g:I18nYamlPath = path
  endif
  call inputrestore()
  return path
endfunction

function! s:askForJsonPath()
  call inputsave()
  let path = ""
  if exists('g:I18nJsonPath')
    let path = g:I18nJsonPath
  else
    let path = input('JSON store: ', 'src/locales/nl.json', 'file')
    let g:I18nJsonPath = path
  endif
  call inputrestore()
  return path
endfunction

vnoremap <leader>z :call I18nTranslateString()<CR>
vnoremap <leader>dt :call I18nDisplayTranslation()<CR>
