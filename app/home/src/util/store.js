/**
 * store.js
 * home
 *
 * 数据存储适配器
 *
 * @author yayowd
 * @since 2021/06/12 20:23
 **/

const store = localStorage

export const saveData = function (name, data) {
    store.setItem(name, data)
}

export const loadData = function (name, defData) {
    return store.getItem(name) || defData
}