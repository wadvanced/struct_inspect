# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2025-10-03

### Added

- Support for map.
- Conditionally ommit the struct key :__struct__ that contains the struct module.

## [0.1.0] - 2025-10-02

### Added

- Initial release of the `StructInspect` library.
- `StructInspect` macro to automatically omit fields with empty values.
- Per-struct configuration for customized inspection behavior.
- Application-wide configuration for consistent settings.
- Support for overriding inspection behavior of third-party structs.
- Comprehensive documentation and specifications for all modules.
- CI pipeline for automated testing and quality assurance.
- Extensive test suite to ensure correctness and stability.
