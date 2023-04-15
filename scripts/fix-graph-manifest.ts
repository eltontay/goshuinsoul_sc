const fs = require('fs');
const yaml = require('js-yaml');
const path = process.argv[2];

try {
  const fileContents = fs.readFileSync(path, 'utf8');
  const data = yaml.load(fileContents);
  data.features = ['ipfsOnEthereumContracts'];

  const newData = {
    specVersion: data.specVersion,
    schema: data.schema,
    features: data.features,
    dataSources: data.dataSources,
  };

  const yamlStr = yaml.dump(newData);
  fs.writeFileSync(path, yamlStr, 'utf8');
} catch (e) {
  console.log(e);
}
