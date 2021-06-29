module.exports = {
    root: true,
    env: {
        node: true,
    },
    extends: [
        'eslint:recommended',
        // 'plugin:vue/vue3-essential',
        'plugin:vue/vue3-recommended',
        // 'plugin:vue/recommended' // Use this if you are using Vue.js 2.x.
        // '@vue/standard', // vue 2.x
        // '@vue/prettier', // vue 2.x // 参见配置文件：prettier.config.js
    ],
    'parser': 'vue-eslint-parser',
    // parserOptions: {
    //     parser: '@babel/eslint-parser',
    // },
    overrides: [{
        'files': ['*.vue'],
        'rules': {
            'indent': 'off',
        },
    }],
    rules: {
        'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
        // 单双引号
        'quotes': ['warn', 'single'],
        // 属性名称引号
        'quote-props': 'off',
        // 尾随逗号
        'comma-dangle': ['error', 'only-multiline'],
        // 行末分号
        'semi': ['error', 'never'],
        // 注释空格
        'spaced-comment': ['warn', 'always'],
        // allow async-await
        'generator-star-spacing': 'off',
        // 缩进
        'indent': ['error', 4],
        // 对象属性列表换行规则：关闭，随意换行
        'object-property-newline': ['off', {
            'allowMultiplePropertiesPerLine': false,
        }],
        // 不允许直接修改内建对象的原型
        'no-extend-native': ['error', {
            'exceptions': ['Date'],
        }],
        'no-irregular-whitespace': ['off', {
            'skipTemplates': true,
        }],
        'vue/script-indent': ['error', 4, {
            'baseIndent': 0,
            'switchCase': 0,
            'ignores': [],
        }],
        'vue/no-parsing-error': ['error', {
            'x-invalid-end-tag': false,
        }],
        // HTML代码缩进4个空格
        'vue/html-indent': ['error', 4, {
            'attribute': 1,
            'baseIndent': 1,
            'closeBracket': 0,
            'alignAttributesVertically': true,
            'ignores': []
        }],
        // 強制HTML标签使用单引号，但是支持引号互斥转义
        'vue/html-quotes': ['error', 'single', {
            'avoidEscape': true,
        }],
        // HTML属性分行不控制
        'vue/max-attributes-per-line': 'off',
        // HTML单行元素内容前后换行不控制
        'vue/singleline-html-element-content-newline': 'off',
    },
}
