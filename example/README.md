## Example 1 

generate validator and DTO for the PetStore `petstore-expanded.yaml` 

### step 1 download the OpenAPI specification file: 
```bash
wget https://raw.githubusercontent.com/valgene/valgene-cli/master/example/petstore-expanded.yaml
```

### step 2 run valgene and let the code generate:
```bash
valgene --template php5.5 --spec petstore-expanded.yaml --option 'php.namespace:\My\PetStore\Api'
```

## Example 2 Payload with array of Objects

generate validator and DTO for the PetStore `container-types.yaml` that shows how an array of Objects is used. 

### step 1 download the OpenAPI specification file: 
```bash
wget https://raw.githubusercontent.com/valgene/valgene-cli/master/example/container-types.yaml
```

### step 2 run valgene and let the code generate:
```bash
valgene --template php5.5 --spec container-types.yaml --option 'php.namespace:\My\PetStore\Api'
```
```
