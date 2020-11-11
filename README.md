# CIMBL API TEST
---
This project is intended to test CIMBL API using the [Karate Framework](https://intuit.github.io/karate/). 

### Prerequisites
1. Java Development Kit
2. Maven

### To Do
1. IAM authentication

### Folder Structure
![Folder Structure](doc/img/folder_structure.png "Folder Structure")

### Running The Tests

IMPORTANT NOTE: IT IS IMPORTANT THAT YOU RUN `gimme-aws-creds` AND CHOOSING THE RIGHT TENANT FOR THE ENVIRONMENT THAT YOU WILL BE RUNNING THE TEST ON.

`./run-test.sh [-r|-runTag <|E2E|CustomTags>] [-e|-env <qa|staging|prod>]`

e.g.

`./run-test.sh -r E2E -e qa`


### Sample Report
![Sample Report](doc/img/sample_report.png "Sample Report")


