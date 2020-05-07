process.env.NODE_ENV = process.env.NODE_ENV || "development";
const environment = require("./environment");

const config = environment.toWebpackConfig();
config.module.strictExportPresence = false
module.exports = config
