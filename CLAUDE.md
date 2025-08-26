# Project Context

## Project Overview

This project is a Ruby CLI app built with the Thor gem.  Its primary purpose is to provide to manage the Semantic Layer hosted in a Strata Server app.  It will used by Data Engineers to configure datasource connection and define the the semantic model.

## Tech Stack

- **Language**: [Ruby]
- **Framework**: Strata Server is a Ruby on Rails app
- **Key Libraries**: [dwh]

## Project Structure

```
/lib          # Source code
/tests        # Test files
/docs         # Documentation
```

## Development Guidelines

### Code Style

- Follow [standardrb style]
- Be succinct and optimize for readability
- Reuse existing code as much as possible
- Do not unnecessarily split a method into multiple methods
  - Split the method when the new method will be used in more than one place
  - Split the method if the method gets to long to maintain readability.
- Use meaningful variable names
- Comment complex logic

### Testing

- Write tests for new features
- Maintain test coverage above [X]%
- Run tests before commits

### Git Workflow

- Use conventional commits
- Create feature branches from main
- Squash commits before merging

## Key Files & Directories

- `[.strata]` - [This CLI will create a .strata file based strata.yml that will contain secrets necessary to access various endpoints.  It will also have config that lets the project connect to the right Strata server.]
- `[cli.rb]` - [main application file]

## Common Tasks

## Architecture Notes

- [Support ruby >= 3.4.4. Cli can be installed as a gem or via shell script.]
- [Follow the style of Ruby on Rails CLI where possible]

## Current Priorities

## Debugging & Troubleshooting

- **Common issue**: Database endpoints are not reachable. This is because we either need to run the requisite docker image or setup a cloud connection to aws snowflake, google etc.
- **Environment setup**: docker compose as needed

## External Resources
