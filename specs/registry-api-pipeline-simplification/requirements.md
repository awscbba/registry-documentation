# Requirements Document

## Introduction

Simplify the registry-api CodeCatalyst pipeline by fixing YAML syntax errors and applying lessons learned from the infrastructure pipeline. Keep it straightforward and reliable.

## Requirements

### Requirement 1

**User Story:** As a developer, I want a simple API pipeline that runs tests and deploys code, so that I can push changes without complex configuration.

#### Acceptance Criteria

1. WHEN I push to a feature branch THEN the pipeline SHALL run tests only
2. WHEN I merge to main THEN the pipeline SHALL run tests and deploy
3. WHEN the pipeline runs THEN it SHALL use simple, clean YAML syntax
4. WHEN tests fail THEN the pipeline SHALL show clear error messages

### Requirement 2

**User Story:** As a developer, I want the API pipeline to work reliably without branch pattern issues, so that I don't waste time on pipeline configuration.

#### Acceptance Criteria

1. WHEN using branch filtering THEN the pipeline SHALL use script logic instead of YAML patterns
2. WHEN running on any branch THEN the pipeline SHALL determine the correct action automatically
3. WHEN YAML syntax errors occur THEN they SHALL be fixed with simple, working patterns
4. WHEN the pipeline triggers THEN it SHALL work consistently across all branch types

### Requirement 3

**User Story:** As a developer, I want basic API testing and deployment, so that code quality is maintained without over-engineering.

#### Acceptance Criteria

1. WHEN code is pushed THEN the pipeline SHALL run unit tests
2. WHEN tests pass THEN the pipeline SHALL run basic linting
3. WHEN on main branch THEN the pipeline SHALL deploy the API
4. WHEN deployment completes THEN the pipeline SHALL verify the API is running