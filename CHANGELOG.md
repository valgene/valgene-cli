## 0.0.1

- minimal working version, far away from feature complete

## 1.0.0

- minimal working version, with bit more examples

## 1.0.1

- implement openAPI default and allOf

## 1.0.2

- implement template-folder cli argument to give customized templates into the engine

## 1.0.3

- implement openAPI nullable on objects that plays well with default

## 1.0.4

- add support for nullable nested types in the openAPI spec, so that arrays of subtypes can be null

## 1.0.5

- refactor the php5.5 template folder so that exceptions are generated just once
- refactor the naming conventions for endpoints to the template by having folders called {{endpoint}} that will be substituted during generation of endpoints 