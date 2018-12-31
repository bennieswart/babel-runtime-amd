const glob = require('glob');
const base = process.argv[2];
const include = ['core-js/shim', 'babel-polyfill', '@babel/runtime/regenerator'].concat(glob.sync('@babel/runtime/helpers/**/*.js', { cwd: `build/${base}` }).map(f => f.replace(/\.js$/, '')));
const conf = {
    name: include[0],
    include: include,
    out: `${base}/bundle.js`,
    findNestedDependencies: true,
    optimize: 'none',
    baseUrl: base,
};
console.log(JSON.stringify(conf, null, 2));
