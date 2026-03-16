# Security

## Security Posture

This repository models a least-privilege, secrets-safe, production-minded data platform.

## Access Principles

- separate ingestion, transformation, analytics, and admin roles
- grant read-only access to marts for broad consumers
- restrict raw and core layers to trusted service and engineering roles
- use IAM roles or service principals instead of embedded secrets

## Sensitive Data Handling

Sensitive fields should be:

- minimized in analytical layers
- masked or tokenized where direct identifiers are unnecessary
- encrypted in transit and at rest
- tagged in metadata for access review and lineage

## Secret Management

- store credentials outside the repository
- reference secrets via environment variables or secret managers
- rotate API keys and service credentials on a defined schedule

## Audit Controls

- log job execution and access to sensitive datasets
- preserve source and transformation provenance
- maintain reproducible run metadata for regulated or finance-sensitive reporting
