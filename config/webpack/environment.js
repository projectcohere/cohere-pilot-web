const { environment } = require("@rails/webpacker")

// add typescript
environment.loaders.prepend(
  "typescript",
  require("./loaders/typescript")
)

// add glob imports to sass-loader
const sass = environment.loaders
  .get("sass")
  .use.find(({ loader: name }) => name === "sass-loader")

const options = sass.options.sassOptions
sass.options.sassOptions = {
  ...options,
  importer: require('node-sass-glob-importer'),
}

console.log(sass)

// export
module.exports = environment
