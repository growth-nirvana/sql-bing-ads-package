# Bing Ads Data Transformations

This repository contains Liquid-templated SQL transformations for Bing Ads data. The transformations are organized into two main categories:

1. **SCD Type 2 Tables**: Slowly Changing Dimension tables that track historical changes
2. **Reporting Tables**: Aggregated tables for reporting and analysis

## Repository Structure

```
.                   # Table definitions and schemas
├── patterns/              # Example transformation patterns
└── transformations/       # Actual SQL transformations
    ├── scd/              # SCD Type 2 transformations
    └── reporting/        # Reporting table transformations
```

## Transformation Patterns

The `patterns` directory contains example transformation patterns that should be followed when creating new transformations. These patterns ensure consistency across all transformations.

## Development Guidelines

1. All SQL transformations should use Liquid templating
2. Follow the established patterns in the `patterns` directory
3. Include appropriate comments and documentation
4. Test transformations before committing

## Getting Started

1. Review the DDL files in the `ddl` directory to understand the table structures
2. Study the patterns in the `patterns` directory
3. Create new transformations following the established patterns 