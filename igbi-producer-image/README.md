# Producer Image
Contains standard pipeline for the  project to build and deploy producer Image.

## Dockerfile
Contains the dockerfile for the generating the producer image. The image is built in the context of /app. Changes here should typically not be required.

## .gitlab-ci.yml
Contains the standard ci yml.

## README.md
Documentation of the project.

## app
Contains the python app used to produce data to kafka


Defined folder structure for deployments
```
- root
  - app
    - cert
      - dgc.crt
      - dgc.perm
      - fsca.crt
      - fsca.perm
      - fwslash.crt
      - iom.crt
    - components
      - connectors
        - stores
          - sqlraptor.py
        - streams
          - kafkaraptor.py
      - pipelines
        - __pycache__
          - pipeline.cpython-39.pyc
        - pipeline.py
      - processors
        - processor.py
    - main.py
    - requirements.txt
  - scripts
    - build.sh
  - Dockerfile   
  - .gitlab-ci.yml
  - README.md
 
```