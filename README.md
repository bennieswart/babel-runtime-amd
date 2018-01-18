# babel-runtime-amd
An AMD version of the [babel-runtime][babel-runtime].

This package allows you to use Babel's [transform-runtime][transform-runtime] plugin in an AMD environment - typically a browser using RequireJS.
I hacked this together because I could not find anything else for this purpose and my search suggests other people might find this useful too.
If you are interested in seeing additional features developed or bugs fixed, don't hesitate to submit an issue on github.

## Install

```bash
npm install babel-runtime-amd --save-dev
```

## Contents

This package contains an AMD version of babel-runtime, as well as AMD versions of its dependencies, core-js and regenerator-runtime. For convenience, it also contains an AMD version of babel-polyfill.
An optimized bundle using RequireJS's r.js is also provided.

## Usage

The following instructions assume a browser environment, but should be adaptable to others.

There are two main ways of using this package: either include the entire bundle before including your own code, or optimize your code against specific files and include only the modules you need.
In both cases, a change to your Babel build configuration is probably required.
If you are using the Babel polyfill, see the notes at the end.

### Configure Babel

Install and configure the [transform-runtime][transform-runtime] plugin for Babel:


```bash
npm i babel-plugin-transform-runtime --save-dev
```
```json
{
    "plugins": [
        ["transform-runtime", {
            "helpers": true,
            "regenerator": true,
            "polyfill": false
        }]
    ]
}
```

### Using the pre-built bundle

Include the bundle using a script tag or load it using RequireJS:
```html
<script src="/js/bundle.min.js"></script>
```
```js
require(['bundle.min']);
```

When bundling your project, add the following to the RequireJS optimizer config:
```js
const glob = require('glob');
let rjsConfig = {
    paths: {
        'babel-runtime': 'path/to/node_modules/babel-runtime-amd/babel-runtime',
        'core-js': 'path/to/node_modules/babel-runtime-amd/core-js',
        'regenerator-runtime': 'path/to/node_modules/babel-runtime-amd/regenerator-runtime',
    },
    excludeShallow: glob.sync('**/*.js', { cwd: 'path/to/node_modules/babel-runtime-amd' }).map(f => f.replace(/\.js$/, '')),
    findNestedDependencies: true,
};
```

This tells RequireJS where to find the `babel-runtime`, `core-js` and `regenerator-runtime` modules during optimization, and then to exclude every module present in `babel-runtime-amd` from the final build, since they are already present in `bundle.min.js`.

### Using only the modules you need

When you don't want to use the pre-built bundle, but only use the modules you actually need, the following configuration should suffice:
```js
let rjsConfig = {
    paths: {
        'babel-runtime': 'path/to/node_modules/babel-runtime-amd/babel-runtime',
        'core-js': 'path/to/node_modules/babel-runtime-amd/core-js',
        'regenerator-runtime': 'path/to/node_modules/babel-runtime-amd/regenerator-runtime',
    },
    findNestedDependencies: true,
};
```

### Notes on the babel-polyfill

It is possible to apply the babel-polyfill when using the pre-built bundle using:
```js
require(['babel-polyfill']);
```
This applies the core-js shim and also includes the regenerator-runtime in a global variable.
If you only want the shim, do:
```js
require(['core-js/shim']);
```

## License

Copyright Bennie Swart.
Licensed under the MIT license.

[babel-runtime]: https://www.npmjs.com/package/babel-runtime
[transform-runtime]: https://babeljs.io/docs/plugins/transform-runtime/
