# Apps Engineering PAD Skills Assessment Supplement

Source: (internal URL)

# Background

T&D is running a **pilot** across Tech to evaluate Skills as part of our performance evaluation process. You have received a few emails from Alex Irwin on the subject, so please review them for background context.

Our group has also received feedback that many employees are looking for more feedback on performance and growth opportunities. We plan to build upon T&D's process to achieve the following:

  * Help managers and direct reports level-set on current skillsets

  * Clarify expectations for core skills

  * Recognize individual strengths and uncover development opportunities to guide growth conversations

  * Identify shared skill gaps to inform team-level training and mentorship opportunities

# FAQ

## Which skills should I select?

See the "Selection Criteria" column in the table. The general principle is to select all skills relevant to your core job execution. Feel free to evaluate any additional skills.

_**Managers should sign off on the list of skills for each individual, so please send your list to your manager for confirmation before evaluating and submitting in Workday.**_

## The instructions from T&D say I only need to fill out 5 skills. Do I need to select more?

Yes. See the goals above for the rationale, and thanks in advance.

## Do I need to add comments for each skill?

No. Feel free to add it if you think it helps justify your rating, but it's not required.

## What's the difference between evaluating Skills, Responsibilities, and Competencies on PAD?

  * **Responsibilities** \- Evaluate outcomes/deliverables of your work

  * **Competencies** \- Evaluate your soft skills, or behavioral traits, like communication, teamwork, and adaptability

  * **Skills** \- Evaluate your [hard skills](https://asana.com/resources/hard-skills-vs-soft-skills) (or specific learned abilities) that you apply to do your job

## What's with the format of some of the skill names?

The skills had to be selected from Workday's static skills database. Your managers did the best they could by selecting the names that matched the skill intention the best.

Reference the "How to Demonstrate" with any questions about what a skill includes.

## Why is there overlap of some of skills?

In a perfect world there would be no overlap, but in practice these skills need to be applied together to deliver software. As an example, we decided for the pilot to separate skills like languages and frameworks, and we'll be re-evaluating this separation in the future.

## What if I have questions or feedback?

Reach out to your manager or Jonah

# Skills Table

**Category**| **Workday Skill**| **Selection Criteria**| **How to Demonstrate**  
---|---|---|---  
Principles| Automated Testing| Required| 

  * Write unit tests to verify individual modules and functions, with appropriate coverage
  * Write integration/API tests that validate how multiple parts of the system interact
  * Run existing tests and use them to facilitate debugging
  * Write unit and integration tests to reproduce known issues
  * Demonstrate facility with testing frameworks used by one's team (e.g. Jest/JUnit/RSpec, etc)
  * Demonstrate facility with mocking tools and frameworks used by one's team
  * Write and refactor source code for testability
  * Unit tests consistently reach appropriate levels of coverage and thoroughness
  * Make appropriate trade-offs between thoroughness and runtime for integration and higher-level tests

  
Principles| Code Reviews| Required| When reviewing code:

  * Provides constructive, empathetic, and rigorous feedback
  * Spots bugs and finds edge cases missed by source code and/or tests
  * Enforces appropriate levels of testability and test coverage
  * Enforces appropriate levels of readability, maintainability, and documentation
  * Ensures consistency with industry and organization-accepted conventions and best practices
  * Appropriately balances tradeoffs between code quality and velocity

  
Principles| Debugging| Required| 

  * Quickly and effectively triages production support issues
  * Uses appropriate debugging tools (e.g., Browser DevTools, Rails console, IntelliJ remote debugger, etc) based on context
  * Traces full data flows--from user input to database and back--to pinpoint failure points
  * Prioritizes root cause analysis over band-aid fixes
  * Reads and interprets logs and stack traces to diagnose issues efficiently

  
Principles| RESTful APIs| Required if contributing to backend web services| 

  * Designs and implements RESTful APIs that enable clear, consistent, and efficient communication between systems and services
  * Demonstrates thoughtful API design that adheres to REST principles, including intuitive endpoints, consistent request/response structures, and proper use of HTTP status codes
  * Defines resource models and applies appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE)
  * Ensures security best practices are _always_ applied, including authentication, authorization, secure transport, and input validation
  * Considers non-functional requirements such as performance, versioning, rate limiting, error handling, idempotency, high availability, and backward compatibility
  * Writes comprehensive documentation using tools such as OpenAPI or Swagger

  
Principles| Software Design Patterns| Required for Senior and above.Optional for Intermediate and Associate| 

  * Demonstrates understanding of common design patterns (e.g. factory, strategy, observer, adapter, decorator, singleton, command, composite, etc) and the categories they fall into (creational, structural, behavioral)
  * Applies design patterns thoughtfully by recognizing appropriate contexts, articulating trade-offs (complexity, extensibility, testability, etc), improving code quality, and avoiding overengineering
  * Applies design principles such as separation of concerns, loose coupling, and high cohesion to support extensibility and long-term maintainability
  * Identifies emerging or implicit design patterns in code and refactors toward abstraction or generalization when it improves clarity and structure
  * Engages in architectural discussions with a design pattern-oriented lens, using shared vocabulary to align solutions across teams

  
Principles| Software Systems Architecture & Design| Required for Staff and above.Optional for Senior, Intermediate, and Associate| 

  * Designs scalable, reliable, and maintainable systems that balance performance, cost, and complexity trade-offs
  * Defines and promotes clear, consistent boundaries and interfaces between domains, services, and components
  * Simplifies or rearchitects legacy systems to align with long-term technical strategy and evolving business needs
  * Drives high-level architectural decisions across domains and guides the evolution of system-wide patterns and standards
  * Demonstrates fluency with architectural paradigms such as microservices, service-oriented architecture (SOA), event-driven architecture, and domain-driven design (DDD)

  
Principles| Writing Technical Documents| Required| 

  * Authors and contributes to technical documentation, including READMEs, RFCs, Confluence docs, system design proposals, and technical sections of PRDs
  * Communicates technical ideas clearly in informal venues such as Slack threads, Jira tickets, and Confluence comments to support shared understanding of decisions, trade-offs, and implementation details
  * Follows best practices for technical writing by producing clear, structured, and concise content tailored to the intended audience (e.g., engineers, product managers, or cross-functional partners)
  * Communicates context, rationale, and implications effectively to reduce ambiguity and ensure documents remain useful to future readers

  
Languages| Java| Required if you use regularly| 

  * Develops and maintains robust, efficient, and maintainable Java code across backend services, APIs, libraries, and tools
  * Contributes to the design and implementation of Java-based systems
  * Debugs and optimizes existing Java code to improve performance and reliability
  * Demonstrates a solid understanding of core Java concepts, including object-oriented design, concurrency, collections, and exception handling
  * Effectively uses Java frameworks and libraries

  
Languages| Javascript| Required if you use regularly| 

  * Demonstrates understanding of JavaScript data types and structures, including Strings, Numbers, Booleans, Objects, and Arrays
  * Applies core JavaScript programming principles such as functions, variables, conditionals, loops, events, immutability, regular expressions, promises, and network requests
  * Uses modern JavaScript syntax and features in line with ESNext (e.g., ES2016/ES7) standards
  * Able to build functionality using plain JavaScript as well as within frameworks such as React
  * Understands how and why to use tools such as Node, NPM, Webpack, Babel, etc
  * Avoids industry-standard anti-patterns such as global variables, unnecessary console.log's, ignoring the Single Responsibility Principle, using magic strings or numbers, failing to handle API call errors, etc
  * Avoids internally agreed-upon anti-patterns such as CMM, Transis, and Statechart, except in cases where their use is unavoidable
  * Writes code designed for testability and builds unit tests with proper coverage using Jest

  
Languages| Python (Programming Language)| Required if you use regularly| 

  * Writes idiomatic Python that aligns with community conventions
  * Demonstrates understanding of core language concepts such as objects, modules, packages, classes, data structures, dynamic typing, functions as first-class objects, list comprehensions, duck typing, etc
  * Applies SOLID object-oriented design principles when structuring Python code
  * Writes code designed for testability and builds unit tests with proper coverage using unittest, pytest, or other widely used testing libraries

  
Languages| Ruby (Programming Language)| Required if you use regularly| 

  * Writes idiomatic Ruby that aligns with community conventions
  * Demonstrates understanding of core language concepts including objects, modules, classes, mixins, blocks, duck typing, metaprogramming, exception handling, etc
  * Applies SOLID object-oriented design principles when structuring Ruby code
  * Writes code designed for testability and builds unit tests with proper coverage using rspec
  * Uses `irb`/`rails console` for experimentation, debugging, and quick prototyping

  
Languages| Serverless Computing| Required if you use regularly| 

  * Designs scalable, maintainable, and cost-efficient architectures using serverless technologies such as AWS Lambda and AWS Glue
  * Configures and manages triggers for serverless jobs and functions
  * Develops, tests, and debugs serverless code with attention to reliability and operational readiness
  * Optimizes serverless workloads for performance and cost efficiency
  * Uses monitoring and observability tools to track, debug, and analyze serverless function behavior in production

  
Languages| Structured Query Language (SQL)| Required if you use regularly| 

  * Writes well-structured, maintainable queries using appropriate join strategies (e.g., inner, left, right, full outer) based on data shape and use case
  * Designs relational schemas, defining tables, indexes, constraints, and relationships to meet application requirements
  * Improves query performance by optimization, tuning, indexes, pruning unnecessary reads, and analyzing execution plans for large datasets
  * Optimizes query performance by analyzing execution plans, tuning queries, managing indexes, and applying strategies like pruning and selective joins, especially when working with large datasets
  * Documents data models and query logic to support team understanding, onboarding, and long-term maintainability

  
Frameworks| React.js| Required if you use regularly| 

  * Builds and maintains React components using props, state, refs, and hooks
  * Demonstrates understanding of component architecture best practices, including separation of concerns, reusability, synchronous vs. asynchronous functionality, error handling, provider patterns, CSS styling approaches, and where/how to manage state
  * Follows internally agreed-upon standards for consistency, including file and directory structure, ESLint rules, use of Design System components, and avoidance of CMM, Statechart, Transis, and transisReact (except when absolutely unavoidable)
  * Demonstrates understanding of key React-dependent libraries such as React Router and React Query
  * Avoids deprecated patterns such as class components, use of `this`, and use of ReactDOM
  * Builds components with testability in mind and writes component unit tests using Jest for proper code coverage

  
Frameworks| Ruby on Rails| Required if you use regularly| 

  * Demonstrates understanding of idiomatic Rails, including configuration conventions, "✨ Rails Magic," and use of the Rails console
  * Manages database interactions, including connection handling, non-downtime schema migrations, and ActiveRecord configurations
  * Builds and maintains models using ActiveRecord, with fluency in associations, validations, scopes, callbacks, enums, single table inheritance, eager loading (`includes`, `preload`, `eager_load`), and custom SQL when appropriate
  * Builds controllers with RESTful and resourceful routing patterns, ensuring proper authorization and security handling
  * Handles multiple response formats (e.g., JSON, HTML) while maintaining separation of concerns in response rendering
  * Uses service classes to encapsulate business logic and integrates async workflows using AMQ events and Sidekiq jobs
  * Applies Rails caching strategies to improve performance and reduce unnecessary computation
  * Writes RSpec tests across models, controllers, views, jobs, and services following established Rails testing patterns

  
Frameworks| Sencha Ext JS| Required if you use regularly| 

  * Demonstrates best practices across core ExtJS constructs, including stores, models, views, controllers, etc
  * Understands how to work within Ext JS conventions, and when to diverge thoughtfully
  * Builds components from scratch and adapts existing components to meet application needs

  
Frameworks| Spring Boot (includes Quarkus)| Required if you use regularly| 

  * Designs, builds, and maintains applications using modern Java frameworks such as Spring Boot or Quarkus
  * Develops RESTful APIs, integrates with databases and external services, and manages application configuration for clarity, flexibility, and scalability
  * Utilizes ORMs where appropriate, applying best practices for data modeling, transaction management, and efficient querying through techniques such as eager loading, pagination, joins, and avoiding N+1 queries
  * Leverages framework-specific features to improve developer productivity, runtime performance, and long-term maintainability
  * Demonstrates fluency in dependency injection, configuration management, and application lifecycle handling
  * Effectively uses annotations, modular components, and built-in framework tools such as Spring Boot starters, Spring Actuator, Spring Data, Quarkus extensions, etc

  
Security| Authorization Management| Required for Auth Team| 

  * Manages frameworks that govern what actions authorized users can perform and which resources they can access within a system
  * Demonstrates knowledge of common authorization models such as Role-Based Access Control (RBAC), Attribute-Based Access Control (ABAC), Relationship-Based Access Control (ReBAC), Fine-Grained Authorization (FGA), resource-based authorization, and hierarchical authorization
  * Identifies and mitigates common vulnerabilities such as privilege escalation, broken access controls, and token manipulation
  * Applies security principles such as least privilege and separation of duties to ensure robust access controls

  
Security| Security Fundamentals| Required| 

  * Understands and applies core security principles across multiple domains of cybersecurity, such as authentication, authorization, encryption, and secure coding practices
  * Manages rules and permissions within authorization frameworks to control what actions authorized users can perform and which resources they can access
  * Demonstrates knowledge of foundational auth topics such as OAuth 2.0, JWT, OpenID Connect, permissions lifecycle management, and privileged account handling
  * Applies industry-standard data security practices such as symmetric vs. asymmetric encryption, hashing algorithms, PKI concepts, proper use of encryption at rest and in transit, and secure management of secrets and configurations
  * Writes automated test cases for common security issues, such as unauthorized users or users without data access
  * Demonstrates understanding of OWASP Top 10 vulnerabilities and applies secure coding practices, including input validation, output encoding, and prevention of SQL injection and cross-site scripting

  
Tools| CI/CD| Required if managing build pipelines| 

  * Display both conceptual understanding and hands-on experience across the entire software delivery pipeline
  * Design CI/CD workflows within CI/CD tools (e.g. Harness), including trigger events, build stages, testing phases, and deployment strategies
  * Display knowledge of pipeline configuration files, build agents, artifact management, and integrations with version control systems
  * Incorporate various testing levels effectively, such as unit tests, integration tests, linters, security scans, and performance testing

  
Tools| Datadog| Required if working on Basis Platform| 

  * **Logs Analysis** \- Ensures application logs include traceable, meaningful metadata and uses Datadog features like search syntax, field grouping, saved views, and Logs Rehydration to investigate issues
  * **APM Trace Analysis** \- Locates and monitors app endpoints to diagnose performance problems and application behavior
  * **Monitors** \- Creates actionable monitors tied to application behavior and tunes thresholds to reduce false positives and improve signal-to-noise ratio
  * **Filtering** \- Filters logs, traces, and metrics by service, environment, session, request, job, host, etc
  * **Dashboards** \- Builds dashboards that visualize system behavior and support debugging, monitoring, and reporting needs
  * **Tool Awareness** \- Chooses the most appropriate Datadog views and tools based on the type of issue or data being investigated

  
Tools| Git| Required| 

  * Manages version control across multiple projects by creating, branching, and merging repositories
  * Contributes to collaborative workflows through pull requests and resolving merge conflicts
  * Maintains clean commit histories by applying merge strategies (e.g., merge, rebase) and writing meaningful commit messages
  * Understands and applies Git workflows such as trunk-based development and Git Flow
  * Documents Git best practices in team guidelines and trains new team members on effective repository management

  
Tools| Kubernetes| Required if you use regularly| 

  * Demonstrates understanding of core Kubernetes concepts and practical experience with container orchestration, resource management, and production deployments
  * Understands pod lifecycle, deployment strategies, and service discovery mechanisms
  * Uses kubectl commands and YAML manifests to manage and troubleshoot cluster resources
  * Writes efficient Dockerfiles, understands layer caching, and implements multi-stage builds
  * Applies image optimization techniques, automates security scanning, and manages image registries
  * Understands container networking, volume mounts, and resource constraints
  * Monitors and debugs pod failures using logging and observability tools
  * Works with Helm Charts, including custom charts with templates, values files, and helper functions
