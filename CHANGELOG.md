# Changelog

## 1.0.11

- fixed #7 strings with default value null came out as "null" 

## 1.0.10

- small improvement on DTO Validator template

## 1.0.9

- more robust validation of nullable values 

## 1.0.8

- migrate to pedantic package for linting
- adding cli parameter version
- adding cli parameter help
- add exception handling on spec file loading, to show potential yaml parsing errors

## 1.0.7

- minor changes that pana suggested
- mockito upgrade

## 1.0.6

- minor naming improvement for validation methods

## 1.0.5

- refactor the php5.5 template folder so that exceptions are generated just once
- refactor the naming conventions for endpoints to the template by having folders called {{endpoint}} that will be substituted during generation of endpoints

## 1.0.4

- add support for nullable nested types in the openAPI spec, so that arrays of subtypes can be null

## 1.0.3

- implement openAPI nullable on objects that plays well with default

## 1.0.2

- implement template-folder cli argument to give customized templates into the engine

## 1.0.1

- implement openAPI default and allOf

## 1.0.0

- minimal working version, with bit more examples

## 0.0.1

- minimal working version, far away from feature complete