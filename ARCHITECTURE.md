# Architecture: uri

## Purpose

League URI — a comprehensive PHP URI manipulation library implementing RFC 3986, RFC 3987 (IRIs), RFC 6570 (URI Templates), and PSR-7 `UriInterface`. Provides immutable URI value objects, a URI builder, scheme-specific subclasses, and URI template expansion.

## Directory Structure

```
Uri.php             - Core immutable URI value object (RFC 3986 + PSR-7 UriInterface)
Http.php            - HTTP/HTTPS specific URI subclass with additional validation
Urn.php             - URN (urn: scheme) specific subclass
BaseUri.php         - Utilities for resolving relative URIs against a base URI
Builder.php         - Fluent URI builder (mutable factory)
UriInfo.php         - Static query helpers: is_absolute(), is_same_origin(), etc.
UriResolver.php     - Resolves relative references per RFC 3986 Section 5
UriScheme.php       - Scheme validation helpers
UriTemplate.php     - RFC 6570 URI Template facade
UriTemplate/
  Template.php      - RFC 6570 template parser and expander
  Expression.php    - Represents a single {expression} in a template
  Operator.php      - Enum of RFC 6570 operators (+, #, ., /, ;, ?, &)
  VarSpecifier.php  - Represents a single variable specifier within an expression
  VariableBag.php   - Holds variable bindings for template expansion
  TemplateCanNotBeExpanded.php - Exception for invalid/missing variable values
HttpFactory.php     - PSR-17 HTTP factory implementation
SchemeType.php      - Enum of URI scheme types (http, ftp, data, file, etc.)
```

## Key Design Decisions

- **Immutable value objects**: All URI objects follow the PSR-7 `withXxx()` convention — mutations return new instances.
- **Scheme-specific subclasses**: `Http`, `Urn`, and data-URI types add scheme-specific validation on top of the base `Uri`.
- **Full RFC 6570 template support**: `UriTemplate` supports all four RFC 6570 expression types (simple, reserved, label, path, query, fragment) with proper percent-encoding.
- **PSR-17 compliance**: `HttpFactory` implements all PSR-17 URI factory interfaces, making the library drop-in with any PSR-7 ecosystem.

## Extension Points

- Extend `Uri` to create scheme-specific URI classes with custom validation.
- Implement custom variable types for `VariableBag` to support non-string template variable types.

## Dependency Flow

```
UriTemplate::expand(['var' => 'value'])
  └─> Template::expand(VariableBag)
        └─> Expression::expand(VariableBag)
              └─> VarSpecifier — applies modifier (truncation, explosion)
              └─> Operator — applies encoding and separator
        └─> returns expanded URI string

Uri::new('https://example.com/path?q=1')
  └─> RFC 3986 parser → immutable Uri value object
  └─> withPath('/new') → new Uri instance
```
