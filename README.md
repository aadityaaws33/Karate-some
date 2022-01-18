# CA SOME TEST AUTOMATION
This project is intended to test CA SOME using the [Karate Framework](https://intuit.github.io/karate/). 

### Prerequisites
1. Java Development Kit
2. Maven

### Running The Tests

IMPORTANT NOTE: 
* IT IS IMPORTANT THAT YOU RUN `gimme-aws-creds` AND CHOOSING THE RIGHT TENANT FOR THE ENVIRONMENT THAT YOU WILL BE RUNNING THE TEST ON.

* SET ENV VARIABLES

`export parallelThreads=10`

`export IconikAdminEmail=rohan_mundkur@discovery.com`

`export IconikAdminPassword=<PASSWORD>`

`export TestUser=<QA_AUTOMATION_USER|rohan_mundkur@discovery.com>`

* RUN TESTS

`./bin/run-test.sh [-t|-tag <Regression|E2E|CustomTags>] [-e|-env <qa|preprod|prod>]`

## NOTES: 

[24 FEB 2022] CURRENTLY ONLY WORKING FOR QA ENVIRONMENT. PROD DOES NOT HAVE SOME PARTNER MODELS AVAILABLE YET.




