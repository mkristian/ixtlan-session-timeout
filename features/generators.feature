Feature: Generators for Ixtlan Audit

  Scenario: The slf4r rails template creates a rails application which uses slf4r-wrapper
    Given I create new rails application with template "simple.template"
    Then the output should contain "setup slf4r logger wrapper with ActiveSupport::BufferedLogger"
