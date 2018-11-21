# API Spec and the implications

### operationId

```yaml
paths:
  /super/long/unintutive/path:
    post:
      operationId: newPet
      requestBody:
        required: true
        content:
          application/json:
            schema:
              \$ref: '#/components/schemas/PostPetsRequest'
```

if the *operationId* is defined, it will be used to generate the endpoint name that is the folder of the generated code.
For the given example the folder will be `PostNewPet`. So the Verb and the *operationId* are combined. 
The *operationId* will overrule the path.