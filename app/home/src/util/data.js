/**
 * data.js
 * home
 *
 * 从页面上获取指定名称的数据
 *
 * @author yayowd
 * @since 2021/06/13 18:44
 **/
import * as R from 'ramda'

function getAttr(el, name) {
    return el.getAttribute(name)
}

function getText(el) {
    const [pre] = el.getElementsByTagName('pre') || []
    if (!R.isNil(pre)) {
        return pre.innerText
    }
}

export function getMeta(id) {
    const el = document.getElementById(id)
    if (!R.isNil(el)) {
        return getText(el)
    }
}

export function getBlock(id) {
    const el = document.getElementById(id)
    if (!R.isNil(el)) {
        return {
            tc: getAttr(el, 'tc'),
            tu: getAttr(el, 'tu'),
            user: getAttr(el, 'user'),
            date: getAttr(el, 'date'),
            text: getText(el),
        }
    }
}