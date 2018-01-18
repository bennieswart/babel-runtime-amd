const path = require('path');
const fs = require('fs');
const mkdirp = require('mkdirp');

let writes = [];
let define = function (name, deps, fn) {
    name = name.replace(/\.js$/, '');
    if (!fn) {
        fn = deps;
        deps = [];
    }
    deps = deps.map(d => d.replace(/\.js$/, ''));
    let strfn = deps.reduce((str, dep) => str.replace(new RegExp(`(["'])${dep}\\.js(["'])`), `$1${dep}$2`), fn.toString());
    writes.push(new Promise((resolve, reject) => {
        let file = path.join('build/dist', name + '.js');
        let data = `define(${JSON.stringify(name)}, ${JSON.stringify(deps)}, ${strfn});`;
        mkdirp(path.dirname(file), mkdirerr => {
            if (mkdirerr) {
                reject(mkdirerr);
            } else {
                fs.writeFile(file, data, writeerr => {
                    if (writeerr) reject(writeerr);
                    resolve();
                });
            }
        });
    }));
};
let content = fs.readFileSync('./build/amd/bundle.js').toString();
(new Function('define', content))(define);
Promise.all(writes).catch(err => {
    console.log(err);
    process.exit(1);
});
