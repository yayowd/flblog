import * as R from 'ramda'

const data = {}

function getAttr(el, name) {
    return el.getAttribute(name)
}

function getText(el) {
    const [pre] = el.getElementsByTagName('pre') || []
    if (!R.isNil(pre)) {
        return pre.innerText
    }
}

function getData(id) {
    const el = document.getElementById(id)
    if (!R.isNil(el)) {
        data[id] = {
            tc: getAttr(el, 'tc'),
            tu: getAttr(el, 'tu'),
            user: getAttr(el, 'user'),
            date: getAttr(el, 'date'),
            text: getText(el),
        }
    }
}

getData('name')
getData('title')
getData('yy')
getData('blog')

export default data