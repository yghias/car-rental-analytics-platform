# CI/CD

## CI Objectives

Continuous integration should ensure that code, SQL, and infrastructure changes are reviewable and safe before merge.

CI should run:

- Python formatting and linting
- unit tests
- basic SQL validation
- import smoke tests for Airflow DAGs and source modules
- notebook JSON sanity checks

## Deployment Objectives

Continuous deployment should package and release:

- ingestion and streaming code artifacts
- Airflow DAG definitions
- infrastructure changes through Terraform plans and applies

## Branch and Promotion Model

- feature branches for implementation
- pull request review for all changes
- main branch as deployable source of truth
- environment-aware deployment with separate secrets and variables

## Guardrails

- fail build on lint or unit test failures
- require terraform plan for infrastructure changes
- separate CI validation from deploy privileges
- enforce secret management through repository or cloud secret stores
