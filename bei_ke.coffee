// ==UserScript==
// @name         贝壳租房筛选器
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  根据关键词去除对应的条目, 提高找房效率
// @author       someone
// @require      http://coffeescript.org/browser-compiler/coffeescript.js
// @grant GM.setValue
// @grant GM.getValue
// @grant GM.deleteValue
// @include         *://xa.zu.ke.com/*
// @match        <$URL$>
// ==/UserScript==

function evalCS(source) {
  // Compile source to Coffeescript (Array)
  var coffeescript = CoffeeScript.compile(source.toString()).split("\n");

  // Prepend 'debugger'
  coffeescript[1] = "debugger;" + coffeescript[1];

  // Join and eval
  eval(coffeescript.join("\n"));
}

// Script Source
// -------------
evalCS(<><![CDATA[

# CoffeeScript here...
# --------------------

main_list_class_name = "content__list"
main_list_element = document.getElementsByClassName(main_list_class_name)[0]
local_db_key = "local_pattern_str"
to_delete = []

select = (collection) -> item for item in collection when item.className is "content__list--item"
remove_from_list = (item) -> main_list_element.removeChild(item)
remove_from_to_delete = () ->
    remove_from_list(item) for item in to_delete
    to_delete = []

pattern_generator = (pattern) ->
    local_pattern = await GM.getValue(local_db_key)
    local_pattern = switch
        when local_pattern is undefined then []
        when local_pattern is '' then []
        else [local_pattern]
    p = switch
        when pattern is '' then []
        when pattern is undefined then []
        else [pattern]
    result = local_pattern.concat(p).join('|')
    await GM.setValue(local_db_key, result)
    result

find_element_with_key = (elements, pattern) ->
    if pattern isnt ''
        item for item in elements when item.textContent.search(RegExp(pattern)) != -1
    else
        []

find_element_with_default_picture = (elements) ->
    is_defalut_img = (element) ->
        img_src = element.Children[0].Children[0].src
        if src.search(pattern) >= 0 then true else false

    pattern = RegExp('/src/resource/default/')
    item for item in elements when is_defalut_img(item)

update_delete_list_with_pattern = (elements, pattern) ->
    to_delete.concat find_element_with_key(elements, pattern)

update_delete_list_with_picture = (elements) ->
    to_delete.concat find_element_with_default_picture(elements)

insert_button_on_click = () ->
    input_element = document.getElementById('input_of_tamp')
    pattern = await pattern_generator input_element.value
    update_delete_list_with_pattern()
    update_delete_list_with_picture()
    remove_from_to_delete()

clear_patterns = () ->
    await GM.deleteValue(local_db_key)
    await insert_pattern_button()

create_insert_box = () ->
    container = document.createElement('div')
    container.innerHTML = '<input type="input" class="input" placeholder="key fo filter" id ="input_of_tamp" />'
    button = document.createElement('div')
    button.innerHTML = '<button id="button_of_tamp" type="button">insert key</button>'
    clear_button = document.createElement('div')
    clear_button.innerHTML = '<button id="clear_button_of_tamp" type="button">clear key</button>'

    main_list_element.parentElement.insertBefore(container, main_list_element)
    main_list_element.parentElement.insertBefore(button, main_list_element)
    main_list_element.parentElement.insertBefore(clear_button, main_list_element)
    document
        .getElementById("button_of_tamp")
        .addEventListener("click", insert_button_on_click, false)
    document
        .getElementById("clear_button_of_tamp")
        .addEventListener("click", clear_patterns, false)

target_elements = select main_list_element.childNodes
create_insert_box()
insert_pattern_button()


]]></>);
